module query.user;

import std.typecons;
import std.variant;
import std.conv;
import std.exception;
import std.stdio;

import relationaldb.all;
import entity.profile;
import entity.user;

class UserQuery
{
    protected RelationalDBInterface relationalDb;

    this(RelationalDBInterface relationalDb) {
        this.relationalDb = relationalDb;
    }

    public bool userExistsById(uint userId)
    {
        enforce(userId > 0, "UserId must be greater than 0");

        string sql = "
                SELECT
                    count(*) as numRows
                FROM
                    usr
                WHERE
                    usrId = ?
            ";

        auto numRows = this.relationalDb.getColumnValueInt(
            sql,
            variantArray(userId)
        );

        return (numRows > 0);
    }

    public bool userExistsByEmail(string emailAddress)
    {
        enforce(emailAddress.length > 5, "Please supply a valid email address");

        string sql = "
                SELECT
                    count(*) as numRows
                FROM
                    usr
                WHERE
                    email = ?
            ";

        auto numRows = this.relationalDb.getColumnValueInt(
            sql,  variantArray(emailAddress)
        );

        return (numRows > 0);
    }

    public User getUserByEmail(in string emailAddress)
    {
        enforce(emailAddress != "", "Please supply a valid email address");

        string sql = "
                SELECT
                    u.usrId, u.email, u.firstName, u.lastName, u.password as passwordHash, newPasswordPin
                FROM
                    usr u
                WHERE
                    u.email = ?
                    AND u.deleted = 0
            ";

        auto user = this.relationalDb.loadRow!User(
            sql,
            variantArray(emailAddress)
        );            

        return user;
    }

    public User getUserById(ulong usrId)
    {
        assert(usrId > 0, "Please supply a valid usrId");
        
        string sql = "
                SELECT
                    u.usrId, u.email, u.firstName, u.lastName, u.password as passwordHash, newPasswordPin
                FROM
                    usr u
                WHERE
                    u.usrId = ?
            ";

        auto user = this.relationalDb.loadRow!User(
            sql,
            variantArray(usrId)
        );            

        return user;
    }

    public Profile getProfileByUserId(ulong usrId)
    {
        assert(usrId > 0, "Please supply a valid usrId");
        
        string sql = "
                SELECT
                    u.email, u.firstName, u.lastName
                FROM
                    usr u
                WHERE
                    u.usrId = ?
            ";

        auto profile = this.relationalDb.loadRow!Profile(
            sql,
            variantArray(usrId)
        );            

        return profile;
    }
}