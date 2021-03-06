module query.token;

import std.typecons;
import std.variant;
import std.conv;
import std.exception;
import std.datetime;
import core.time;

import relationaldb.all;
import entity.token;

class TokenQuery
{
    protected RelationalDBInterface relationalDb;

    this(RelationalDBInterface relationalDb) @safe
    {
        this.relationalDb = relationalDb;
    }

    public bool existsByCode(string tokenCode) @trusted
    {
        enforce(tokenCode != "", "Please provide a valid token code");

        string sql = "
                SELECT
                    count(*) as numRows
                FROM
                    token
                WHERE
                    tokenCode = ?
            ";

        auto numRows = this.relationalDb.getColumnValueInt(
            sql,
            variantArray(tokenCode)
        );

        return (numRows > 0);
    }

    public Token getByCode(in string tokenCode) @trusted
    {
        enforce(tokenCode != "", "Please provide a valid token code");
        
        string sql = "
                SELECT
                    t.tokenCode, t.ipAddress, t.userAgent, t.prefix, t.expiresAt, t.usrId, t.usrType
                FROM
                    token t
                WHERE
                    t.tokenCode = ?
            ";

        auto token = this.relationalDb.loadRow!Token(
            sql,
            variantArray(tokenCode)
        );            

        return token;
    }    
}