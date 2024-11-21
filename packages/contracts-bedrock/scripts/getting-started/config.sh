#!/usr/bin/env bash

# This script is used to generate the getting-started.json configuration file
# used in the Getting Started quickstart guide on the docs site. Avoids the
# need to have the getting-started.json committed to the repo since it's an
# invalid JSON file when not filled in, which is annoying.

reqenv() {
    if [ -z "${!1}" ]; then
        echo "Error: environment variable '$1' is undefined"
        exit 1
    fi
}

# Check required environment variables
reqenv "GS_ADMIN_ADDRESS"
reqenv "GS_BATCHER_ADDRESS"
reqenv "GS_PROPOSER_ADDRESS"
reqenv "GS_SEQUENCER_ADDRESS"
reqenv "L1_RPC_URL"

# Get the finalized block timestamp and hash
block=$(cast block finalized --rpc-url "$L1_RPC_URL")
timestamp=$(echo "$block" | awk '/timestamp/ { print $2 }')
blockhash=$(echo "$block" | awk '/hash/ { print $2 }')

# Generate the config file
config=$(cat << EOL
{
  "l1StartingBlockTag": "$blockhash",
  "l1ChainID": 11155111,
  "l2ChainID": 902,
  "l2BlockTime": 2,
  "maxSequencerDrift": 600,
  "sequencerWindowSize": 3600,
  "channelTimeout": 300,
  "l1UseClique": false,
  "cliqueSignerAddress": "0x0000000000000000000000000000000000000000",
  "p2pSequencerAddress": "$GS_SEQUENCER_ADDRESS",
  "batchInboxAddress": "0x42000000000000000000000000000000000000ff",
  "batchSenderAddress": "$GS_BATCHER_ADDRESS",
  "l2OutputOracleSubmissionInterval": 120,
  "l2OutputOracleStartingBlockNumber": 0,
  "l2OutputOracleStartingTimestamp": $timestamp,
  "l2OutputOracleProposer": "$GS_PROPOSER_ADDRESS",
  "l2OutputOracleChallenger": "$GS_ADMIN_ADDRESS",
  "l1BlockTime": 2,
  "l1GenesisBlockNonce": "0x0",
  "l1GenesisBlockGasLimit": "0x1c9c380",
  "l1GenesisBlockDifficulty": "0x1",
  "finalSystemOwner": "$GS_ADMIN_ADDRESS",
  "superchainConfigGuardian": "$GS_ADMIN_ADDRESS",
  "finalizationPeriodSeconds": 12,
  "l1GenesisBlockMixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "l1GenesisBlockCoinbase": "0x0000000000000000000000000000000000000000",
  "l1GenesisBlockNumber": "0x0",
  "l1GenesisBlockGasUsed": "0x0",
  "l1GenesisBlockParentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "l1GenesisBlockTimestamp": "0x0",
  "l1GenesisBlockBaseFeePerGas": "0x3b9aca00",
  "l2GenesisBlockNonce": "0x0",
  "l2GenesisBlockGasLimit": "0x1c9c380",
  "l2GenesisBlockDifficulty": "0x1",
  "l2GenesisBlockMixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "l2GenesisBlockNumber": "0x0",
  "l2GenesisBlockGasUsed": "0x0",
  "l2GenesisBlockParentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "l2GenesisBlockBaseFeePerGas": "0x3b9aca00",
  "l2GenesisBlockExtraData": "bm9uLWRlZmF1bHQgdmFsdWU=",
  "baseFeeVaultRecipient": "$GS_ADMIN_ADDRESS",
  "l1FeeVaultRecipient": "$GS_ADMIN_ADDRESS",
  "sequencerFeeVaultRecipient": "$GS_ADMIN_ADDRESS",
  "baseFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "l1FeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "sequencerFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "baseFeeVaultWithdrawalNetwork": 0,
  "l1FeeVaultWithdrawalNetwork": 0,
  "sequencerFeeVaultWithdrawalNetwork": 0,
  "l1StandardBridgeProxy": "0x42000000000000000000000000000000000000f8",
  "l1CrossDomainMessengerProxy": "0x42000000000000000000000000000000000000f9",
  "l1ERC721BridgeProxy": "0x4200000000000000000000000000000000000060",
  "systemConfigProxy": "0x4200000000000000000000000000000000000061",
  "optimismPortalProxy": "0x4200000000000000000000000000000000000062",
  "proxyAdminOwner": "$GS_ADMIN_ADDRESS",
  "gasPriceOracleOverhead": 2100,
  "gasPriceOracleScalar": 100000000,
  "enableGovernance": false,
  "governanceTokenSymbol": "OP",
  "governanceTokenName": "Optimism",
  "governanceTokenOwner": "$GS_ADMIN_ADDRESS",
  "deploymentWaitConfirmations": 1,
  "eip1559Denominator": 8,
  "eip1559DenominatorCanyon": 12,
  "eip1559Elasticity": 2,
  "fundDevAccounts": false,
  "faultGameAbsolutePrestate": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "faultGameMaxDepth": 63,
  "faultGameMaxDuration": 604800,
  "faultGameGenesisBlock": 0,
  "faultGameGenesisOutputRoot": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "faultGameSplitDepth": 0,
  "preimageOracleMinProposalSize": 1800000,
  "preimageOracleChallengePeriod": 86400,
  "preimageOracleCancunActivationTimestamp": 0,
  "systemConfigStartBlock": 0,
  "requiredProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "recommendedProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "proofMaturityDelaySeconds": 12,
  "disputeGameFinalityDelaySeconds": 6,
  "respectedGameType": 0,
  "useFaultProofs": false
}
EOL
)

# Write the config file
echo "$config" > deploy-config/getting-started.json

