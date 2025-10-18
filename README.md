# baziqbrowser
Navegador web experimental, usa Qt/QtWebEngine,  com suporte para acesso à rede Tor

> [!IMPORTANT]
Foi testado apenas em sistema linux

**Instruções para instalar dependências, compilar e rodar:**

consultar a sua distribuição linux;

exemplo de comandos no alpinelinux:

instalar Qt:

` # apk add qt6-qtwebengine-dev qt6-qtsvg-dev  `

compilar:

```
$ mkdir build
$ cd build
$ cmake ..
$ make
```

> [!TIP]
para rodar:
` $ ./baziqbrowser `

> [!TIP]
para instalar (opcional):
` # make install `

instalar Tor (opcional):

no alpinelinux:

` # apk add tor`

rodar Tor:

no alpinelinux:

` # rc-service tor start`

se for em distros com systemd:

` # systemctl start tor `

verificar status:

no alpinelinux:

` # rc-service tor status`

se for em distros com systemd:

` # systemctl status tor `

> [!NOTE]
Esse projeto atualmente é parte de um trabalho acadêmico do curso sistemas de informação UFSC
