# baziqbrowser
Navegador web experimental, usa Qt/QtWebEngine,  com suporte para acesso à rede Tor

> [!IMPORTANT]
Foi testado apenas em sistema linux

**Instruções para instalar dependências, compilar e rodar:**

linux fedora v41:

instalar Qt:

` sudo dnf install qt6-qtwebengine-devel `

compilar:

```
mkdir build
cd build
cmake ..
make
```

instalar Tor:

` sudo dnf install tor `

rodar Tor:

` sudo systemctl start tor `

verificar status:

` sudo systemctl status tor `

> [!TIP]
para rodar:
` ./baziqbrowser `

> [!NOTE]
Esse projeto atualme é parte de um trabalho acadêmico do curso sistemas de informação UFSC
