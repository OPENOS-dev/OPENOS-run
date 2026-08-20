/* openos-run — 独立 App (自包含, 可单独构建)
 * Win10 风格开始菜单启动器
 */
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QUrl>
#include "iconloader.h"
#include "iconprovider.h"
#include "apps.h"

int main(int argc, char** argv) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("openos-run");
    app.setQuitOnLastWindowClosed(true);

    QQmlApplicationEngine engine;

    engine.addImageProvider(QStringLiteral("icons"), new IconProvider);
    IconLoader iconLoader(&app);
    engine.rootContext()->setContextProperty("_iconLoader", &iconLoader);

    QQmlComponent token(&engine, QUrl(QStringLiteral("qrc:/qml/OpenUI.qml")));
    QObject* openUI = token.create();
    engine.rootContext()->setContextProperty("OpenUI", openUI);

    /* 应用模型 + 启动器 (pacman 系统应用 + vmapp 隔离应用) */
    AppsModel apps;
    AppLauncher launcher;
    apps.refresh();
    engine.rootContext()->setContextProperty("appsModel", &apps);
    engine.rootContext()->setContextProperty("appLauncher", &launcher);

    engine.load(QUrl(QStringLiteral("qrc:/qml/Launcher.qml")));
    return engine.rootObjects().isEmpty() ? 1 : app.exec();
}
