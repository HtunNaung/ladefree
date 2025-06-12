#!/bin/bash

export UUID=${UUID:-'f3f6f78e-b7da-4cfb-9aaf-7b3a3f7988b2'} # 哪吒v1,在不同的平台部署需要改UUID，否则会覆盖
export NEZHA_SERVER=${NEZHA_SERVER:-''}       # v1哪吒填写形式：nezha.abc.com:8008,v0哪吒填写形式：nezha.abc.com
export NEZHA_PORT=${NEZHA_PORT:-''}           # v1哪吒不要填写这个,v0哪吒agent端口为{443,8443,2053,2083,2087,2096}其中之一时自动开启tls
export NEZHA_KEY=${NEZHA_KEY:-''}             # v1的NZ_CLIENT_SECRET或v0的agent密钥
export ARGO_DOMAIN='lade.burmese.dpdns.org'   # 固定隧道域名,留空即启用临时隧道
export ARGO_AUTH='{"AccountTag":"0a78e2086b33db962360e43b0369fc08","TunnelSecret":"h9sMxkqNX2CQaYZK5Dysxo4S3W+U1J3zb/hOtWaMKsg=","TunnelID":"3a6b6407-ad17-4de3-9817-93405c4c1a7d","Endpoint":""}' # 固定隧道token或json,留空即启用临时隧道
export CFIP='www.digitalocean.com'             # argo节点优选域名或优选ip
export CFPORT='443'                            # argo节点端口 
export NAME='lade'                            # 节点名称，去掉多余的 }
export FILE_PATH=${FILE_PATH:-'./.npm'}       # sub 路径  
export ARGO_PORT=${ARGO_PORT:-'8001'}         # argo端口 使用固定隧道token,cloudflare后台设置的端口需和这里对应
export TUIC_PORT=${TUIC_PORT:-'40000'}        # Tuic 端口，支持多端口玩具可填写，否则不动
export HY2_PORT=${HY2_PORT:-'50000'}          # Hy2 端口，支持多端口玩具可填写，否则不动
export REALITY_PORT=${REALITY_PORT:-'60000'}  # reality 端口,支持多端口玩具可填写，否则不动   
export CHAT_ID=${CHAT_ID:-''}                 # TG chat_id，可在https://t.me/laowang_serv00_bot 获取
export BOT_TOKEN=${BOT_TOKEN:-''}             # TG bot_token, 使用自己的bot需要填写,使用上方的bot不用填写,不会给别人发送
export UPLOAD_URL=${UPLOAD_URL:-''}            # 订阅自动上传地址,没有可不填,需要填部署Merge-sub项目后的首页地址,例如：https://merge.serv00.net

# 之后脚本...
