// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

//
function dbInit()
{
    let dbHistory = LocalStorage.openDatabaseSync("History_DB_" + profileName, "", "", 1000000)
    let dbBookmark = LocalStorage.openDatabaseSync("Bookmark_DB_" + profileName, "", "", 1000000)
    try {
        dbHistory.transaction(function (tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS history (title text,url text,icon text)')
        })
        dbBookmark.transaction(function (tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS bookmark (title text,url text,icon text)')
            tx.executeSql('CREATE UNIQUE INDEX idx_bookmark_url ON bookmark (url)')
        })
    } catch (err) {
        console.log("Error creating table in database: " + err)
    };
}

function historyDbGetHandle()
{
    try {
        var dbHistory = LocalStorage.openDatabaseSync("History_DB_" + profileName, "","", 1000000)
    } catch (err) {
        console.log("Error opening database: " + err)
    }
    return dbHistory
}

function bookmarkDbGetHandle()
{
    try {
        var dbBookmark = LocalStorage.openDatabaseSync("Bookmark_DB_" + profileName, "","", 1000000)
    } catch (err) {
        console.log("Error opening database: " + err)
    }
    return dbBookmark
}

function historyDbInsert(Ptitle, Purl, Picon)
{
    let dbHistory = historyDbGetHandle()
    let rowid = 0;
    dbHistory.transaction(function (tx) {
        tx.executeSql('INSERT INTO history VALUES(?, ?, ?)', [Ptitle, Purl, Picon])
        let result = tx.executeSql('SELECT last_insert_rowid()')
        rowid = result.insertId
    })
    //return rowid;
}

function bookmarkDbInsert(Ptitle, Purl, Picon)
{
    let dbBookmark = bookmarkDbGetHandle()
    let rowid = 0;
    dbBookmark.transaction(function (tx) {
        tx.executeSql('REPLACE INTO bookmark VALUES(?, ?, ?)', [Ptitle, Purl, Picon])
        let result = tx.executeSql('SELECT last_insert_rowid()')
        rowid = result.insertId
    })
    //return rowid;
}

function historyDbReadAll()
{
    let dbHistory = historyDbGetHandle()
    dbHistory.transaction(function (tx) {
        let results = tx.executeSql(
                'SELECT rowid,title,url,icon FROM history GROUP BY url ORDER BY COUNT(url) DESC')
        for (let i = 0; i < results.rows.length; i++) {
            historyModel.append({
                                 id: results.rows.item(i).rowid,
                                 title: results.rows.item(i).title,
                                 url: results.rows.item(i).url,
                                 icon: results.rows.item(i).icon
                             })
        }
    })
}

function bookmarkDbReadAll()
{
    let dbBookmark = bookmarkDbGetHandle()
    dbBookmark.transaction(function (tx) {
        let results = tx.executeSql(
                'SELECT rowid,title,url,icon FROM bookmark')
        for (let i = 0; i < results.rows.length; i++) {
            bookmarkModel.append({
                                 id: results.rows.item(i).rowid,
                                 title: results.rows.item(i).title,
                                 url: results.rows.item(i).url,
                                 icon: results.rows.item(i).icon
                             })
        }
    })
}

function bookmarkDbReadUrl(Purl)
{
    let dbBookmark = bookmarkDbGetHandle()
    let result = ""
    dbBookmark.transaction(function (tx) {
        let results = tx.executeSql(
                'SELECT url FROM bookmark WHERE url = ?', [Purl])

        for (let i = 0; i < results.rows.length; i++) {
                result = results.rows.item(i).url
        }
    })
    //print(result)
    return result
}

function historyDbClear()
{
    let dbHistory = historyDbGetHandle()
    dbHistory.transaction(function (tx) {
        tx.executeSql('delete from history')
    })
}

function bookmarkDbClear()
{
    let dbBookmark = bookmarkDbGetHandle()
    dbBookmark.transaction(function (tx) {
        tx.executeSql('delete from bookmark')
    })
}

function bookmarkDbDeleteRow(Prowid)
{
    let dbBookmark = bookmarkDbGetHandle()
    dbBookmark.transaction(function (tx) {
        tx.executeSql('delete from bookmark where rowid = ?', [Prowid])
    })
}
