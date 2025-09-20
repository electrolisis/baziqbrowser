// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include "utils.h"

#include <QtWebEngineQuick/qtwebenginequickglobal.h>

#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QGuiApplication>
// #ifdef QT_WIDGETS_LIB
// #include <QApplication>
// #else
// #include <QGuiApplication>
// #endif

#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QLoggingCategory>

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
    //return QUrl(QStringLiteral("about:blank"));
    //return QUrl(QStringLiteral("chrome:qt"));
    return QUrl(QStringLiteral(""));
}

int main(int argc, char **argv)
{
    QCoreApplication::setApplicationName("Baziqbrowser");
    QCoreApplication::setOrganizationName("BaziqProject");
    QCoreApplication::setApplicationVersion("0.1");

    QtWebEngineQuick::initialize();

    QGuiApplication app(argc, argv);
// #ifdef QT_WIDGETS_LIB
//     QApplication app(argc, argv); // only for Qt.labs.platform components
// #else
//     QGuiApplication app(argc, argv);
// #endif

    QLoggingCategory::setFilterRules(QStringLiteral("qt.webenginecontext.debug=true"));

    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument("url", "The URL to open.");
    //
    const QCommandLineOption profileOption("profile", "The profile to use.", "profile");
    parser.addOption(profileOption);

    const QCommandLineOption torOption("tor", "Use Tor network.");
    parser.addOption(torOption);
    //

    parser.process(app);

    // https://doc.qt.io/qt-6/qtquickcontrols2-styles.html
    //QQuickStyle::setStyle("Fusion");
    //QQuickStyle::setStyle("Basic");
    //QQuickStyle::setStyle("Imagine");
    //QQuickStyle::setStyle("FluentWinUI3");

    QQmlApplicationEngine appEngine;
    appEngine.load(QUrl("qrc:/ApplicationRoot.qml"));
    if (appEngine.rootObjects().isEmpty())
        qFatal("Failed to load sources");

    //
    if (parser.isSet(profileOption)) {
        const QString profile = parser.value(profileOption);
        QMetaObject::invokeMethod(appEngine.rootObjects().constFirst(),
                              "setProfile", Q_ARG(QVariant, profile));
    }
    //

    //
    if (parser.isSet(torOption)) {
        //Tor network
        QNetworkProxy proxy;
        proxy.setType(QNetworkProxy::Socks5Proxy);
        proxy.setHostName("localhost");
        proxy.setPort(9050);
        QNetworkProxy::setApplicationProxy(proxy);
        //
    }
    //

    const QUrl url = startupUrl(parser);

    QMetaObject::invokeMethod(appEngine.rootObjects().constFirst(),
                              "load", Q_ARG(QVariant, url));

    return app.exec();
}
