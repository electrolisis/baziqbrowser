// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

//
//  W A R N I N G
//  -------------
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY.
//

#include "utils.h"

#include <QtWebEngineQuick/qtwebenginequickglobal.h>

#include <QQmlApplicationEngine>
#include <QQmlContext>

// #ifdef QT_WIDGETS_LIB
//#include <QApplication>
// #else
#include <QGuiApplication>
// #endif

#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QLoggingCategory>

#include <QQuickStyle>

#include <QSettings>

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

// #ifdef QT_WIDGETS_LIB
//     QApplication app(argc, argv); //
// #else
     QGuiApplication app(argc, argv);
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

    QQmlApplicationEngine appEngine;

    //
    QSettings settings;
    if (parser.isSet(profileOption)) {
        //qDebug() << "qDebug ----- profile: " << parser.value(profileOption);
        settings.beginGroup(parser.value(profileOption));
    }else{
        settings.beginGroup("default");
    }

    // If this is the first time we're running the application,
    // we need to set a style in the settings so that the QML
    // can find it in the list of built-in styles.
    const QString styleInSettings = settings.value("style").toString();
    if (styleInSettings.isEmpty())
        settings.setValue(QLatin1String("style"), "System");
    if (settings.value("style").toString() != "System")
        QQuickStyle::setStyle(settings.value("style").toString());
    //
    //qDebug() << "qDebug ----- main.cpp style: " << settings.value("style").toString();

    // https://doc.qt.io/qt-6/qtquickcontrols2-styles.html
    //QQuickStyle::setStyle("Fusion");
    //QQuickStyle::setStyle("Basic");
    //QQuickStyle::setStyle("Imagine");
    //QQuickStyle::setStyle("FluentWinUI3");

    QStringList builtInStyles;

    //
    builtInStyles << QLatin1String("System");

    builtInStyles << QLatin1String("Basic");
    builtInStyles << QLatin1String("Fusion");
    //builtInStyles << QLatin1String("Imagine");
    //builtInStyles << QLatin1String("Material");
    //builtInStyles << QLatin1String("Universal");
    //builtInStyles << QLatin1String("FluentWinUI3");

#if defined(Q_OS_MACOS)
    builtInStyles << QLatin1String("macOS");
    builtInStyles << QLatin1String("iOS");
#elif defined(Q_OS_IOS)
    builtInStyles << QLatin1String("iOS");
#elif defined(Q_OS_WINDOWS)
    builtInStyles << QLatin1String("Windows");
#endif
    //if kde
    //builtInStyles << QLatin1String("org.kde.desktop");

    //qDebug() << "builtInStyles ----- " << builtInStyles;

    //qDebug() << " ----- QLocale::languageToString: " << QLocale::languageToString( QLocale().language());
    //qDebug() << " ----- QLocale::languageToCode: " << QLocale::languageToCode( QLocale().language());
    //qDebug() << " ----- QLocale::territoryToCode: " << QLocale::territoryToCode(QLocale().territory());

    QString httpAcceptLanguageString;

    QString territoryToCodeString = QLocale::territoryToCode(QLocale().territory());

    if(territoryToCodeString.isEmpty()){
           httpAcceptLanguageString = QLocale::languageToCode(QLocale().language());
       }else{
        httpAcceptLanguageString = QLocale::languageToCode(QLocale().language())
                +"-"+territoryToCodeString;
       }

    qDebug() << " ----- httpAcceptLanguageString: " << httpAcceptLanguageString;

    appEngine.setInitialProperties({
        { "builtInStyles", builtInStyles },
        { "httpAcceptLanguageString", httpAcceptLanguageString }
    });
    //

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
