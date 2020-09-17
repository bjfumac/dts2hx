#  TypeScript Definitions to Puerhx Converter

源项目为https://github.com/haxiomic/dts2hx。我根据puerts的特点魔改了一下，可以将绑定代码生成对应的haxe提示文件。

## 安装
1. 项目下载到本地，保证已经安装了npm和haxe
2. 进入项目文件夹 执行 `haxelib install hxnodejs`
3. `npm run prepare`
4. `npm install -g`
5. 将index.d.ts文件拷贝到任意名称为node_modules的文件夹，然后在该文件夹下执行 `dts2hx index`
6. 将生成的代码拷贝到Assets文件夹下即可(通过`dts2hx index -o xxx/Assets/` 省略该步骤)
