#include "utils.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtWebEngine/QtWebEngine>

static QUrl startupUrl()
{
    QUrl ret;
    QStringList args(qApp->arguments());
    args.takeFirst();
    Q_FOREACH (const QString& arg, args) {
        if (arg.startsWith(QLatin1Char('-')))
             continue;
        ret = Utils::fromUserInput(arg);
        if (ret.isValid())
            return ret;
    }
    return QUrl(QStringLiteral("http://dot.kde.org"));
}

int main(int argc, char **argv)
{
    qputenv("QTWEBENGINE_DIALOG_SET", "QtQuickControls2");

    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

    QApplication app(argc, argv);

    QtWebEngine::initialize();

    QQmlApplicationEngine appEngine;
    Utils utils;
    appEngine.rootContext()->setContextProperty(QStringLiteral("utils"), &utils);
    appEngine.load(QUrl("qrc:/ApplicationRoot.qml"));
    QMetaObject::invokeMethod(appEngine.rootObjects().first(), "load", Q_ARG(QVariant, startupUrl()));

    return app.exec();
}
