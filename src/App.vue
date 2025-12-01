

<template>

  <div class="container">
    <h1>WETH 兑换器 (合约交互入门)</h1>

    <button v-if="!account" @click="connectWallet" class="btn">🔌 连接钱包</button>

    <div v-else>
      <p>当前账号: {{ account.slice(0,6) }}...{{ account.slice(-4) }}</p>

      <div class="card">
        <h3>我的 WETH 余额</h3>
        <p class="balance">{{ wethBalance }} WETH</p>
      </div>

      <hr>

      <button @click="wrapETH" class="btn swap-btn">
        🔄 把 0.01 ETH 换成 WETH
      </button>

      <div v-if="txStatus" class="status-box">{{ txStatus }}</div>
    </div>
  </div>
</template>

<script setup>

/* 你刚才转的是 ETH，这是区块链自带的。 但是，你未来工作中遇到的 99% 的资产都不是 ETH，而是 ERC-20 代币（如 USDT、UNI、SHIB）或者 NFT。
ETH 转账： 不需要“说明书”，直接发。

代币/合约交互： 必须有 “说明书” (ABI)，否则前端不知道怎么跟合约说话。

🎯 下一步目标：做一个“ETH 包装器” (WETH Wrapper)
我们要利用你手里的测试网 ETH，通过调用智能合约，把它变成 WETH (Wrapped ETH)。
什么是 WETH？ 它是一个 ERC-20 代币（像 USDT 一样）。把 ETH 存进去，就变成 WETH；取出来，又变回 ETH。
技术点： 你将第一次使用 ABI 和 ethers.Contract 对象。

1. 核心概念：ABI (应用二进制接口)
你可以把它理解为 API 文档的 JSON 版。
后端给你的 API 文档写着：POST /user/login。
合约给你的 ABI 写着：function deposit() payable。
2. 代码实战 (App.vue)
我们要修改代码，引入一个 WETH 的合约地址和它的 ABI。
请将 App.vue 替换为以下代码：  */

import { ref } from 'vue'
import { ethers } from 'ethers'

const account = ref('')
const wethBalance = ref('0.0') // 专门用来存 WETH 余额
const txStatus = ref('')

// 1. Sepolia 测试网的 WETH 合约地址 (这是一个真实存在的合约)
const WETH_ADDRESS = "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14"

// 2. ABI (说明书)：我们只需要用到两个功能
// - balanceOf: 查余额
// - deposit: 存 ETH 换 WETH
const WETH_ABI = [
"function balanceOf(address owner) view returns (uint256)", // 这是读！
  "function deposit() payable"                                // 这是写！
]

const connectWallet = async () => {
  if (!window.ethereum) return alert('请安装 MetaMask')
  const provider = new ethers.BrowserProvider(window.ethereum)
  const signer = await provider.getSigner()
  account.value = await signer.getAddress()

  // 连接成功后，立刻查一下 WETH 余额
  await getWethBalance(signer)
}

// 读取合约数据 (Read)
const getWethBalance = async (signer) => {
  // 核心代码：创建一个合约实例
  // new ethers.Contract(地址, ABI, 谁在操作)
  const wethContract = new ethers.Contract(WETH_ADDRESS, WETH_ABI, signer)

  // 调用合约方法，像调 JS 函数一样简单
  const balance = await wethContract.balanceOf(account.value)
  wethBalance.value = ethers.formatEther(balance)
}

// 写入合约数据 (Write - 也是一种交易)
const wrapETH = async () => {
  txStatus.value = "正在唤起钱包..."
  try {
    const provider = new ethers.BrowserProvider(window.ethereum)
    const signer = await provider.getSigner()

    // 1. 实例化合约
    const wethContract = new ethers.Contract(WETH_ADDRESS, WETH_ABI, signer)

    // 2. 调用 deposit 方法
    // 注意：deposit 是付费方法，所以要带上 { value: ... }
    const tx = await wethContract.deposit({ value: ethers.parseEther("0.01") })

    txStatus.value = `交易发送成功！Hash: ${tx.hash}\n等待打包...`

    // 3. 等待上链
    await tx.wait()

    txStatus.value = "✅ 兑换成功！你获得了 0.01 WETH"

    // 4. 刷新余额看看
    await getWethBalance(signer)

  } catch (error) {
    console.error(error)
    txStatus.value = "❌ 交易失败"
  }
}
</script>


<style scoped>
.container { max-width: 500px; margin: 50px auto; text-align: center; font-family: sans-serif; }
.btn { padding: 12px 24px; font-size: 16px; cursor: pointer; background: #333; color: #fff; border: none; border-radius: 8px; }
.swap-btn { background: #6200ea; width: 100%; margin-top: 20px; }
.card { background: #f4f4f4; padding: 20px; border-radius: 12px; margin-top: 20px; }
.balance { font-size: 32px; font-weight: bold; color: #6200ea; margin: 10px 0; }
.status-box { margin-top: 20px; padding: 15px; background: #e0e0e0; border-radius: 8px; word-break: break-all; }
</style>
