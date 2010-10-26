// -*-  Mode:java; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

package org.tmurakam.cashflow.ormapper;

import java.util.ArrayList;
import android.database.sqlite.SQLiteDatabase;
import android.database.Cursor;

import org.tmurakam.cashflow.ormapper.Database;

public class ORRecord {
    private static final String pkey = "key";

    private int pid; // primary key
    private boolean isInserted;

    public int pid() {
        return this.pid;
    }
    public void setPid(int pid) {
        this.pid = pid;
    }

    // constructor
    ORRecord() {
        isInserted = false;
    }

    /**
       @brief Migrate database table
    */
    static public boolean migrate(String[] array) {
        SQLiteDatabase db = Database.instance();
        boolean ret;
        String tablesql;

        // check if table exists.
        String sql = "SELECT sql FROM sqlite_master WHERE type='table' AND name='?'";
        String[] params = {tableName()};
        Cursor cursor = db.rawQuery(sql, params);
        cursor.moveToFirst();

        // create table
        if (cursor.getCount() == 0) {
            sql = "CREATE TABLE " + tableName() + " (" + pkey + 
                " INTEGER PRIMARY KEY);";
            db.execSQL(sql);
            tablesql = sql;
            ret = true;
        } else {
            cursor.moveToFirst();
            tablesql = cursor.getString(0);
            ret = false;
        }
        cursor.close();

        // add columns
        int count = array.length / 2;

        for (int i = 0; i < count; i++) {
            String column = array[i * 2];
            String type = array[i * 2 + 1];

            if (tablesql.indexOf(" " + column + " ") < 0) {
                sql = "ALTER TABLE " + tableName() + " ADD COLUMN " + 
                    column + " " + type + ";";
                db.execSQL(sql);
            }
        }
        return ret;
    }

    /**
       @brief get all records
       @return array of all record
    */
    public static ArrayList find_all() {
        return find_cond(null);
    }

    /**
       @brief get all records matche the conditions

       @param cond Conditions (WHERE phrase and so on)
       @return array of records

       You must override this.
    */
    public static ArrayList find_cond(String cond) {
        return null;
    }

    /**
       @brief get the record matchs the id
       
       @param id Primary key of the record
       @return record
    */
    public static ORRecord find(int pid) {
        return null;
    }

    /**
       @brief Save record
    */
    public void save() {
        if (isInserted) {
            update();
        } else {
            insert();
        }
    }

    public static String tableName() {
        return null; // must be override
    }

    public void insert() {
        isInserted = true;
        return;
    }

    public void update() {
        return;
    }

    /**
       @brief Delete record
    */
    public void delete() {
        return;
    }

    public static void delete_all() {
        // must be override
    }
    
}
