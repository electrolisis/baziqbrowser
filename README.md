# baziqbrowser
Navegador web experimental, usa Qt/QtWebEngine,  com suporte para acesso à rede Tor

> [!IMPORTANT]
Compila e roda em: Linux, Ms windows e MacOs.
> Foi testado apenas em sistema Linux.

**Instruções para instalar dependências, compilar e rodar em Linux:**

Consultar a sua distribuição linux.

Referência de comandos em uma distribuição baseada em debian:

instalar Qt:

` # apt install cmake qt6-webengine-dev `

compilar:

```
$ mkdir build
$ cd build
$ cmake ..
$ make
```
para rodar:
` $ ./baziqbrowser `

para instalar (opcional):
` # make install `

instalar Tor (opcional):

` # apt install tor `

rodar Tor:

` # systemctl start tor `

verificar status:

` # systemctl status tor `

rodar Tor na inicialização do sistema:

` # systemctl enable tor `

> [!NOTE]
Esse projeto atualmente é parte de um trabalho acadêmico do curso sistemas de informação UFSC
