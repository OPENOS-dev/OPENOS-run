// openos-run — 应用模型 + 启动器后端 (C++)
// 扫描 pacman 安装的系统应用 (/usr/share/applications)
// 与 vmapp 隔离环境 (/vmapp/<app>/usr/share/applications),
// 供 Launcher.qml (Win10 开始菜单) 使用。
#pragma once
#include <QAbstractListModel>
#include <QObject>
#include <QStringList>

struct RunApp {
    QString name;
    QString exec;
    QString vmapp;   // 非空 = 隔离环境应用
    QString source;  // "system" = pacman/系统, "vmapp" = 隔离
    QString icon;
    QString group;   // 首字母 (Win10 所有应用分界)
};

class AppsModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Role { NameRole = Qt::UserRole + 1, ExecRole, VmappRole,
                SourceRole, IconRole, GroupRole };
    explicit AppsModel(QObject* parent = nullptr) : QAbstractListModel(parent) {}

    int rowCount(const QModelIndex& = {}) const override { return m_items.size(); }
    QVariant data(const QModelIndex& idx, int role) const override {
        if (idx.row() < 0 || idx.row() >= m_items.size()) return {};
        const RunApp& a = m_items[idx.row()];
        switch (role) {
        case NameRole:  return a.name;
        case ExecRole:  return a.exec;
        case VmappRole: return a.vmapp;
        case SourceRole: return a.source;
        case IconRole:  return a.icon;
        case GroupRole: return a.group;
        }
        return {};
    }
    QHash<int, QByteArray> roleNames() const override {
        return { {NameRole,"name"}, {ExecRole,"exec"}, {VmappRole,"vmapp"},
                 {SourceRole,"source"}, {IconRole,"icon"}, {GroupRole,"group"} };
    }

    Q_INVOKABLE void refresh();

private:
    void scanDesktopDir(const QString& dir, const QString& vmapp, const QString& source);
    QVector<RunApp> m_items;
};

// 启动器: 启动系统应用 / 隔离应用
class AppLauncher : public QObject {
    Q_OBJECT
public:
    using QObject::QObject;
    Q_INVOKABLE void launch(const QString& exec);
    Q_INVOKABLE void launchInVmapp(const QString& vmapp, const QString& exec);
};
