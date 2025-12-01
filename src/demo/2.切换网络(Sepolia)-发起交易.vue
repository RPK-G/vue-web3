
<template>
  <div class="container">
    <h1>Web3 转账 Demo (Sepolia)</h1>

    <button v-if="!isConnected" @click="connectWallet" class="btn">
      🔌 连接钱包 & 切网
    </button>

    <div v-else class="wallet-info">
      <p><strong>你的地址:</strong> {{ account }}</p>
      <p><strong>你的余额:</strong> {{ balance }} SepoliaETH</p>

      <hr />

      <button @click="sendTransaction" class="btn send-btn">
        💸 给自己转 0.0001 ETH
      </button>

      <div v-if="txStatus" class="status-box">
        {{ txStatus }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ethers } from 'ethers'

const account = ref('')
const balance = ref('')
const isConnected = ref(false)
const txStatus = ref('') // 用来显示交易状态

// 定义 Sepolia 测试网的参数
const SEPOLIA_ID = '0xaa36a7' // 十六进制的 11155111

const connectWallet = async () => {
  if (!window.ethereum) return alert('请安装 MetaMask！')

  try {
    const provider = new ethers.BrowserProvider(window.ethereum)
    const signer = await provider.getSigner()

    // 1. 获取地址
    account.value = await signer.getAddress()
    isConnected.value = true

    // 2. 检查网络：如果不是 Sepolia，就请求切换
    const network = await provider.getNetwork()
    console.log(network);

    // chainId 是 bigint 类型，需要转换比较
    if (network.chainId !== 11155111n) {
      await switchNetwork()
    }

    // 3. 刷新余额
    await refreshBalance(provider)

  } catch (error) {
    console.error("连接错误:", error)
  }
}

// 新增功能：切换到 Sepolia 测试网
const switchNetwork = async () => {
  try {
    await window.ethereum.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId: SEPOLIA_ID }],
    })
  } catch (error) {
    // 如果用户钱包里没添加过 Sepolia (虽然现在 MetaMask 默认都有)，这里需要处理 wallet_addEthereumChain
    alert("请在 MetaMask 手动切换到 Sepolia 测试网！")
  }
}

// 辅助函数：刷新余额
const refreshBalance = async (provider) => {
  const balanceBigInt = await provider.getBalance(account.value)
  console.log(balanceBigInt);

  balance.value = ethers.formatEther(balanceBigInt)
  console.log(balance.value);

}

// 新增功能：发起转账 (给自己转 0.0001 ETH)
const sendTransaction = async () => {
  if (!account.value) return
  txStatus.value = '正在唤起钱包...'

  try {
    const provider = new ethers.BrowserProvider(window.ethereum)
    const signer = await provider.getSigner()

    // 发起交易
    const tx = await signer.sendTransaction({
      to: account.value, // 给自己转，省得找别人地址
      value: ethers.parseEther("0.0001") // 0.0001 ETH
    })

    txStatus.value = `交易已发送！Hash: ${tx.hash}\n等待上链中...`

    // 等待交易确认 (类似 await axios)
    await tx.wait()

    txStatus.value = '✅ 交易成功！余额已更新。'
    await refreshBalance(provider)

  } catch (error) {
    console.error(error)
    txStatus.value = '❌ 交易取消或失败'
  }
}
</script>


<style scoped>
.container { text-align: center; margin-top: 50px; font-family: sans-serif; }
.btn { padding: 10px 20px; font-size: 16px; cursor: pointer; background: #4CAF50; color: white; border: none; border-radius: 4px; }
.send-btn { background: #2196F3; margin-top: 10px; }
.wallet-info { background: #f5f5f5; padding: 20px; display: inline-block; border-radius: 8px; border: 1px solid #ddd; }
.status-box { margin-top: 15px; padding: 10px; background: #e8e8e8; border-radius: 4px; white-space: pre-wrap; font-family: monospace; }
</style>
