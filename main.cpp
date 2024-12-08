// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include "utils.h"

#include <QtWebEngineQuick/qtwebenginequickglobal.h>

#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>

#include <QtGui/QGuiApplication>

#include <QtCore/QCommandLineParser>
#include <QtCore/QCommandLineOption>
#include <QtCore/QLoggingCategory>

#include <QQuickStyle>

//
#include <QNetworkProxy>

static QUrl startupUrl(const QCommandLineParser &parser)
{
    if (!parser.positionalArguments().isEmpty()) {
        const QUrl url = Utils::fromUserInput(parser.positionalArguments().constFirst());
        if (url.isValid())
            return url;
    }
    return QUrl(QStringLiteral("about:blank"));
}

int main(int argc, char **argv)
{
    QCoreApplication::setApplicationName("Baziqbrowser");
    QCoreApplication::setOrganizationName("BaziqProject");
    QCoreApplication::setApplicationVersion("0.1");

    QtWebEngineQuick::initialize();

    QGuiApplication app(argc, argv);
    QLoggingCategory::setFilterRules(QStringLiteral("qt.webenginecontext.debug=true"));

    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument("url", "The URL to open.");
    parser.process(app);

    // https://doc.qt.io/qt-6/qtquickcontrols2-styles.html
    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine appEngine;
    appEngine.load(QUrl("qrc:/ApplicationRoot.qml"));
    if (appEngine.rootObjects().isEmpty())
        qFatal("Failed to load sources");

    //Tor network
    QNetworkProxy proxy;
    proxy.setType(QNetworkProxy::Socks5Proxy);
    proxy.setHostName("localhost");
    proxy.setPort(9050);
    QNetworkProxy::setApplicationProxy(proxy);
    //

    const QUrl url = startupUrl(parser);
    QMetaObject::invokeMethod(appEngine.rootObjects().constFirst(),
                              "load", Q_ARG(QVariant, url));

    return app.exec();
}
