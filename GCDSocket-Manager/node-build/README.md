# 安装：
1. 运行：`brew install node`来安装Node.js
2. 在终端中切换到`build.js`的所在目录中
3. 运行`sudo npm install`
4. 安装完毕后使用`node build`来运行脚本


# 示例
**请在终端切换到build.js目录下**

`node build --bug 10294`

编译测试环境MyMoneyPro_#10294T.ipa，并自动复制ipa到测试服务器的Feature目录下。

`node build --beta --set-version 9.7.1`

编译内测包MyMoneyEnterprise_v9.7.1.ipa，并自动复制ipa到测试服务器的Version目录下。
     
`node build --release --set-version 9.7.1`

编译正式环境MyMoneyPro_v9.7.1_AdHoc.ipa，并自动复制ipa到测试服务器的Version目录下。
     
`node build --conf Debug --scheme MyMoney --forced-name haha --local --show-output`

编译标准版，Debug，名字haha.ipa，不复制到测试服务器，显示xcodebuild的详细log。

     
更多帮助请运行：`node build --help`，有详细的命令列表。

# 协议
MIT, 有任何问题请立即反馈给Mgen.