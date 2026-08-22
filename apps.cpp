/*
 * Copyright (C) 2026 OPENOS-dev
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the OPENOS-PROJECT-LICENSE (OPL) v1.2.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * OPL for more details.
 *
 * You should have received a copy of the OPL along with this program.
 * If not, see <https://github.com/OPENOS-dev/OPL>.
 */

// openos-run — 应用模型 + 启动器后端实现
#include "apps.h"
#include <QDir>
#include <QFile>
#include <QProcess>
#include <QRegularExpression>

/* 扫描 .desktop: 解析 Name/Exec/Icon, 跳过 NoDisplay/Hidden, 字母分组, 去重 */
void AppsModel::scanDesktopDir(const QString& dir, const QString& vmapp,
                               const QString& source) {
    QDir d(dir);
    if (!d.exists()) return;
    const QFileInfoList entries = d.entryInfoList(QStringList() << "*.desktop",
                                                   QDir::Files);
    for (const QFileInfo& fi : entries) {
        QFile f(fi.absoluteFilePath());
        if (!f.open(QIODevice::ReadOnly)) continue;
        QString name, exec, icon;
        bool hide = false, inEntry = false;
        while (!f.atEnd()) {
            const QString line = QString::fromUtf8(f.readLine()).trimmed();
            if (line == QLatin1String("[Desktop Entry]")) inEntry = true;
            else if (line.startsWith(QLatin1Char('['))) inEntry = false;
            if (!inEntry) continue;
            if (line.startsWith(QLatin1String("Name="))) name = line.mid(5);
            else if (line.startsWith(QLatin1String("Exec="))) exec = line.mid(5);
            else if (line.startsWith(QLatin1String("Icon="))) icon = line.mid(5);
            else if (line.startsWith(QLatin1String("NoDisplay=")) && line.mid(10).startsWith(QLatin1Char('t'))) hide = true;
            else if (line.startsWith(QLatin1String("Hidden=")) && line.mid(7).startsWith(QLatin1Char('t'))) hide = true;
        }
        if (hide || name.isEmpty() || exec.isEmpty()) continue;
        for (const RunApp& a : m_items)
            if (a.source == source && a.name == name && a.exec == exec) { hide = true; break; }
        if (hide) continue;
        QChar c = name.at(0).toUpper();
        QString group = c.isLetter() ? QString(c) : QStringLiteral("#");
        m_items.append({name, exec, vmapp, source, icon, group});
    }
}

void AppsModel::refresh() {
    beginResetModel();
    m_items.clear();
    /* pacman 安装的系统软件 */
    scanDesktopDir(QStringLiteral("/usr/share/applications"), QString(), QStringLiteral("system"));
    scanDesktopDir(QStringLiteral("/usr/local/share/applications"), QString(), QStringLiteral("system"));
    /* vmapp 隔离环境: 生产经 libvmapp 枚举; 原型枚举常见目录 */
    const QStringList vmapps = { QStringLiteral("opt"), QStringLiteral("firefox"), QStringLiteral("code") };
    for (const QString& app : vmapps)
        scanDesktopDir(QStringLiteral("/vmapp/%1/usr/share/applications").arg(app), app, QStringLiteral("vmapp"));
    endResetModel();
}

/* 启动系统应用: 剥离 % 字段符, 后台分离执行 */
void AppLauncher::launch(const QString& exec) {
    QString cmd = exec;
    cmd.remove(QRegularExpression(QStringLiteral("\\s%-?[a-zA-Z]*")));  // 去 %f %U 等
    QProcess::startDetached(cmd);
}

/* 启动隔离应用: 生产经 libvmapp 在对应环境内执行; 原型直接分离执行 */
void AppLauncher::launchInVmapp(const QString& vmapp, const QString& exec) {
    Q_UNUSED(vmapp);
    launch(exec);
}
