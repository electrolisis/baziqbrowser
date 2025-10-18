# baziqbrowser
Navegador web experimental, usa Qt/QtWebEngine,  com suporte para acesso à rede Tor

> [!IMPORTANT]
Foi testado apenas em sistema linux

**Instruções para instalar dependências, compilar e rodar:**

linux:

instalar Qt:

qt6 (...) qtwebengine (...) devel

` ... `

compilar:

```
mkdir build
cd build
cmake ..
make
```

instalar Tor:

` ... `

rodar Tor:

` sudo systemctl start tor `

verificar status:

` sudo systemctl status tor `

> [!TIP]
para rodar:
` ./baziqbrowser `

> [!NOTE]
Esse projeto atualmente é parte de um trabalho acadêmico do curso sistemas de informação UFSC
