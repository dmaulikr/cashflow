#!/usr/bin/ruby

=begin
  O/R Mapper library for iPhone

  Copyright (c) 2010, Takuya Murakami. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
=end

$LOAD_PATH.push(File.expand_path(File.dirname($0)))

require "schema.rb"

VER = "0.1(cashflow)"
PKEY = "key"

def getJavaType(type)
    case type
    when "INTEGER"
        return "int";
    when "REAL"
        return "double";
    when "TEXT"
        return "String";
    when "DATE"
        return "Date";
    else
        puts "#{type} is not supported."
        exit 1
    end
end

def getMethodType(type)
    case type
    when "INTEGER"
        return "Int"
    when "REAL"
        return "Double"
    when "TEXT"
        return "String"
    when "DATE"
        return "Date"
    else
        puts "#{type} not supported"
        exit 1
    end
end

#
# generate implementation
#
def generateImplementation(cdef, fh)
    fh.puts <<EOF
// Generated by O/R mapper generator ver #{VER}

package org.tmurakam.cashflow.ormapper;

import java.util.*;
import android.content.ContentValues;
import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.ORRecord;

public class #{cdef.bcname} extends ORRecord {
    public long pid;
    protected boolean isInserted = false;

EOF
    cdef.members.each do |m|
        type = getJavaType(cdef.types[m])
        fh.puts "    public #{type} #{m};"
    end
    fh.puts

    fh.puts <<EOF

    /**
      @brief Migrate database table
      @return YES - table was newly created, NO - table already exists
    */
    public static boolean migrate() {
        String[] columnTypes = {
EOF

    cdef.members.each do |m|
        fh.puts "        \"#{m}\", \"#{cdef.types[m]}\","
    end

    fh.puts <<EOF
        };

        return migrate(columnTypes);
    }

    /**
      @brief allocate entry
    */
    public static #{cdef.bcname} allocator() {
        return new #{cdef.bcname}();
    }

    // Read operations

    /**
      @brief get the record matchs the id

      @param pid Primary key of the record
      @return record
    */
    public static #{cdef.bcname} find(int pid) {
        SQLiteDatabase db = Database.instance();

        String[] param = { Integer.toString(pid) };
        Cursor cursor = db.rawQuery("SELECT * FROM #{cdef.name} WHERE key = ?;", param);

        #{cdef.bcname} e = null;
        cursor.moveToFirst();
        if (!cursor.isAfterLast()) {
            e = allocator();
            e._loadRow(cursor);
        }
        cursor.close();
 
        return e;
    }
    /**
       @brief get all records matche the conditions

       @param cond Conditions (WHERE phrase and so on)
       @return array of records
    */
    public static ArrayList<#{cdef.bcname}> find_cond(String cond) {
        return find_cond(cond, null);
    }

    public static ArrayList<#{cdef.bcname}> find_cond(String cond, String[] param) {
        String sql;
        sql = "SELECT * FROM #{cdef.name}";
        if (cond != null) {
            sql += " ";
            sql += cond;
        }
        SQLiteDatabase db = Database.instance();
        Cursor cursor = db.rawQuery(sql, param);
        cursor.moveToFirst();

        ArrayList<#{cdef.bcname}> array = new ArrayList<#{cdef.bcname}>();

        while (!cursor.isAfterLast()) {
            #{cdef.bcname} e = allocator();
            e._loadRow(cursor);
            array.add(e);
        }
        return array;
    }

    private void _loadRow(Cursor cursor) {
        this.pid = cursor.getInt(0);
EOF

    i = 1
    cdef.members.each do |m|
        type = cdef.types[m];
        if (type == "DATE")
            fh.puts "        this.#{m} = Database.str2date(cursor.getString(#{i}));"
        else    
            method = getMethodType(type);
            fh.puts "        this.#{m} = cursor.get#{method}(#{i});"
        end
        i+=1
    end

    fh.puts <<EOF

        isInserted = true;
    }

    // Create operations

    public void insert() {
        super.insert();

        SQLiteDatabase db = Database.instance();

        this.pid = db.insert("#{cdef.name}", "key"/*TBD*/, getContentValues());

        //[db commitTransaction];
        isInserted = true;
    }

    // Update operations

    public void update() {
        super.update();

        SQLiteDatabase db = Database.instance();
        //[db beginTransaction];

        ContentValues cv = getContentValues();

        String[] whereArgs = { Long.toString(pid) };
        db.update("#{cdef.name}", cv, "WHERE key = ?", whereArgs);

        //[db commitTransaction];
    }

    private ContentValues getContentValues()
    {
        ContentValues cv = new ContentValues(#{cdef.members.length});
EOF

    i = 1
    cdef.members.each do |m|
        if (cdef.types[m] == "DATE")
            fh.puts "        cv.put(\"#{m}\", Database.date2str(this.#{m}));"
        else
            fh.puts "        cv.put(\"#{m}\", this.#{m});"
        end
    end

    fh.puts <<EOF

        return cv;
    }

    // Delete operations

    /**
       @brief Delete record
    */
    public void delete() {
        SQLiteDatabase db = Database.instance();

        String[] whereArgs = { Long.toString(pid) };
        db.delete("#{cdef.name}", "WHERE key = ?", whereArgs);
    }

    /**
       @brief Delete all records
    */
    public static void delete_cond(String cond) {
        SQLiteDatabase db = Database.instance();

        if (cond == null) {
            cond = "";
        }
        String sql = "DELETE FROM #{cdef.name} " + cond;
        db.execSQL(sql);
    }

    // Internal functions

    public static String tableName() {
        return "#{cdef.name}";
    }
}
EOF

end

# start from here
if (ARGV.size != 1)
    STDERR.puts "usage: #{$0} [deffile]"
    exit 1
end

schema = Schema.new
schema.loadFromFile(ARGV[0])
#schema.dump

# generate
schema.defs.each do |cdef|
    STDERR.puts "generate #{cdef.bcname}.java"
    fh = open(cdef.bcname + ".java", "w")
    generateImplementation(cdef, fh)
    fh.close
end
