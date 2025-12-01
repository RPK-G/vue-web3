<template>
  <div class="container">
    <h1>我的 Web3 Demo</h1>

    <button v-if="!isConnected" @click="connectWallet" class="btn">🔌 连接钱包</button>

    <div v-else class="wallet-info">
      <p><strong>你的地址:</strong> {{ account }}</p>
      <p><strong>你的余额:</strong>ETH {{ balance }}</p>
    </div>
  </div>
</template>
<script setup>
import { ref } from "vue";
import { ethers } from "ethers"; // 引入 ethers 库

const account = ref(""); // 用来存用户的地址
const balance = ref("0.0"); // 用来存用户的余额
const isConnected = ref(false);

// 核心函数：连接钱包
const connectWallet = async () => {
  // 1. 检查浏览器有没有安装钱包插件
  if (!window.ethereum) {
    alert("请先安装 MetaMask！");
    return;
  }

  try {
    // 2. 创建一个 BrowserProvider (基于浏览器的提供者)
    // 以前老版本叫 Web3Provider，ethers v6 改名了，注意区分
    const provider = new ethers.BrowserProvider(window.ethereum);

    // 3. 发送请求，弹出 MetaMask 窗口让用户授权
    // getSigner() 会自动触发 eth_requestAccounts
    const signer = await provider.getSigner();

    // 4. 拿到用户地址
    account.value = await signer.getAddress();
    isConnected.value = true;

    // 5. 顺便查一下余额 (查出来是 BigInt，要转成字符串)
    const balanceBigInt = await provider.getBalance(account.value);
    // formatEther 把 Wei (最小单位) 转成 ETH
    balance.value = ethers.formatEther(balanceBigInt);
    console.log(balance.value);
  } catch (error) {
    console.error("连接出错:", error);
  }
};
</script>

<style scoped>
.container {
  text-align: center;
  margin-top: 50px;
}
.btn {
  padding: 10px 20px;
  font-size: 16px;
  cursor: pointer;
}
.wallet-info {
  background: #f0f0f0;
  padding: 20px;
  display: inline-block;
  border-radius: 8px;
}
</style>
