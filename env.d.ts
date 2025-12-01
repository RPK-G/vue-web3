/// <reference types="vite/client" />
/*
这是一个非常经典的 TypeScript 配置问题。

原因： TypeScript 默认只认识 .ts 文件，不认识 .vue 文件。
 在本地开发时，VS Code 里的 Volar 插件帮你“作弊”处理了这个问题，
 所以你本地可能不报错。 但在 CI 环境（GitHub Actions）里，
 执行 vue-tsc (TypeScript 检查) 时，它发现没有人告诉它 .vue 到底是什么，于是报错。
*/
declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  // eslint-disable-next-line @typescript-eslint/no-explicit-any, @typescript-eslint/ban-types
  const component: DefineComponent<{}, {}, any>
  export default component
}
