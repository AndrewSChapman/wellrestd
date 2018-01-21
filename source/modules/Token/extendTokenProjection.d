module projections.auth.extendtoken;

import vibe.vibe;
import std.variant;
import std.datetime;
import core.time;

import relationaldb.all;
import entity.sessioninfo;
import commands.extendtoken;
import helpers.helperfactory;

class ExtendTokenProjection
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private RedisDatabase redisDatabase;
    private ExtendTokenCommandMeta meta;
    private const uint tokenTimeoutInSeconds = 3600;

    this(
        RelationalDBInterface relationalDb,
        RedisDatabase redisDatabase,
        ExtendTokenCommandMeta meta
    ) {
        this.relationalDb = relationalDb;
        this.redisDatabase = redisDatabase;
        this.meta = meta;
    }

    void handleEvent() {
        this.extendToken();
    }

    private long currentUnixTime()
    {
        return Clock.currTime().toUnixTime();
    }     

    private long generateExpiryTime() {
        return this.currentUnixTime() + this.tokenTimeoutInSeconds;
    }     

    public void extendToken() {
        string sql = "
                UPDATE token SET expiresAt = ? 
                WHERE tokenCode = ?
            ";    

        ulong newExpiryTime = this.generateExpiryTime();   

        this.relationalDb.execute(sql, variantArray(
            newExpiryTime,
            this.meta.tokenCode
        )); 

        // Store the session info and expiry in redis.
        SessionInfo sessionInfo;

        if (this.redisDatabase.exists(this.meta.tokenCode)) {
            Json sessionInfoJson = parseJsonString(this.redisDatabase.get(this.meta.tokenCode));
            sessionInfo = deserializeJson!SessionInfo(sessionInfoJson);
        } else {
			sessionInfo.prefix = this.meta.prefix;
			sessionInfo.usrId = this.meta.usrId;
            sessionInfo.userAgent = this.meta.userAgent;
            sessionInfo.ipAddress = this.meta.ipAddress;  
        }

        sessionInfo.expiresAt = newExpiryTime;
        this.redisDatabase.set(this.meta.tokenCode, sessionInfo.serializeToJsonString());	
    }     
}