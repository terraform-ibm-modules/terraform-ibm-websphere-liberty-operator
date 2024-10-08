// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const completeExampleDir = "examples/complete"

func setupOptions(t *testing.T, prefix string, exampleDir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  exampleDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		IgnoreUpdates: testhelper.Exemptions{ // Ignore for consistency check
			List: []string{
				// to skip update error due to operator sample app updates
				"module.websphere_liberty_operator.helm_release.websphere_liberty_operator_sampleapp[0]",
				// to skip update error due to operator catalog image version updates
				"module.websphere_liberty_operator.helm_release.ibm_operator_catalog[0]",
			},
		},
		ImplicitDestroy: []string{
			// workaround for the issue https://github.ibm.com/GoldenEye/issues/issues/10743
			// when the issue is fixed on IKS, so the destruction of default workers pool is correctly managed on provider/clusters service the next two entries should be removed
			"'module.ocp_base.ibm_container_vpc_worker_pool.autoscaling_pool[\"default\"]'",
			"'module.ocp_base.ibm_container_vpc_worker_pool.pool[\"default\"]'",
		},
	})
	return options
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "wslo-upg", completeExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunSLZExample(t *testing.T) {
	t.Parallel()

	// ------------------------------------------------------------------------------------
	// Deploy SLZ ROKS Cluster first since it is needed for the WAS extension input
	// ------------------------------------------------------------------------------------
	logger.Log(t, "Starting TestRunSLZExample")
	prefix := fmt.Sprintf("was-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := "./resources"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "variable "+checkVariable+" correctly set")

	// Verify region variable is set, otherwise it computes it
	region := ""
	checkRegion := "TF_VAR_region"
	valRegion, presentRegion := os.LookupEnv(checkRegion)
	if presentRegion {
		region = valRegion
	} else {
		// Programmatically determine region to use based on availability
		region, _ = testhelper.GetBestVpcRegion(val, "../common-dev-assets/common-go-assets/cloudinfo-region-vpc-gen2-prefs.yaml", "eu-de")
	}

	logger.Log(t, "Using region: ", region)

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix":        prefix,
			"region":        region,
			"resource_tags": tags,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	logger.Log(t, "Selecting or creating workspace")
	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	logger.Log(t, "Running init & apply")
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		logger.Log(t, "Init and apply failed")
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
	} else {
		logger.Log(t, "Going now to deploy WAS extension")
		// ------------------------------------------------------------------------------------
		// Deploy WAS extension
		// ------------------------------------------------------------------------------------

		rbacSynchSleepTime := 180
		logger.Log(t, fmt.Sprintf("Sleeping for %d seconds to allow RBAC to sync", rbacSynchSleepTime))
		time.Sleep(time.Duration(rbacSynchSleepTime) * time.Second)

		options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
			Testing:      t,
			TerraformDir: "extensions/landing-zone",
			// Do not hard fail the test if the implicit destroy steps fail to allow a full destroy of resource to occur
			ImplicitRequired: false,
			ImplicitDestroy: []string{
				// workaround for the issue https://github.ibm.com/GoldenEye/issues/issues/10743
				// when the issue is fixed on IKS, so the destruction of default workers pool is correctly managed on provider/clusters service the next two entries should be removed
				"'module.ocp_base.ibm_container_vpc_worker_pool.autoscaling_pool[\"default\"]'",
				"'module.ocp_base.ibm_container_vpc_worker_pool.pool[\"default\"]'",
			},
			TerraformVars: map[string]interface{}{
				"cluster_id": terraform.Output(t, existingTerraformOptions, "workload_cluster_id"),
				"region":     terraform.Output(t, existingTerraformOptions, "region"),
			},
		})

		output, err := options.RunTestConsistency()
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}
