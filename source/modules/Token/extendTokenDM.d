module decisionmakers.extendtoken;

import std.exception;
import std.stdio;

import vibe.vibe;

import validators.all;
import command.decisionmakerinterface;
import command.all;
import entity.token;
import commands.extendtoken;
import helpers.testhelper;

struct ExtendTokenFacts
{
    bool tokenExists;
    ulong tokenExpiry;
    string tokenUserAgent;
    string tokenIPAddress;
    string tokenCode;
    string userAgent;
    string ipAddress;
    string prefix;
    ulong usrId;
    uint usrType;
}

class ExtendTokenDM : AbstractDecisionMaker,DecisionMakerInterface
{
    private ExtendTokenFacts facts;
    
    public this(in ref ExtendTokenFacts facts) @safe
    {
        enforce(facts.tokenExists, "Sorry, your login token is invalid.");
        enforce(facts.tokenExpiry > Clock.currTime().toUnixTime(), "Sorry, your login token has expired.");
        enforce(facts.tokenCode != "", "Please supply a valid tokenCode.");
        enforce(facts.userAgent != "", "Please supply a valid userAgent.");
        enforce(facts.userAgent == facts.tokenUserAgent, "Sorry, your login token has an invalid user agent.");
        enforce(facts.ipAddress == facts.tokenIPAddress, "Sorry, your login token has an invalid IP address.");
        enforce(facts.prefix != "", "Prefix may not be blank.");

        (new Varchar255Required(facts.ipAddress, "ipAddress"));
        (new PositiveNumber!ulong(facts.usrId, "usrId"));            

        this.facts = facts;
        this.executeCommandsAsyncronously = false;
    }

    public void issueCommands(CommandBusInterface commandBus) @safe
    {        
        auto command = new ExtendTokenCommand(
            this.facts.tokenCode,
            this.facts.userAgent,
            this.facts.ipAddress,
            this.facts.prefix,
            this.facts.usrId,
            this.facts.usrType
        );

        commandBus.append(command, typeid(ExtendTokenCommand));
    }
}

unittest {
    // Test passing facts
    ExtendTokenFacts[] passingFactsArray;
    passingFactsArray ~= ExtendTokenFacts(true, Clock.currTime().toUnixTime() + 99999999, "test.useragent", "127.0.0.1", "MyTokenCode", "test.useragent", "127.0.0.1", "MyPrefix", 1);

    foreach(facts; passingFactsArray) {
        TestHelper.testDecisionMaker!(ExtendTokenDM, ExtendTokenFacts)(facts, 1, false);
    }

    // Test failing facts
    ExtendTokenFacts[] failingFactsArray;
    failingFactsArray ~= ExtendTokenFacts(false, Clock.currTime().toUnixTime() + 99999999, "test.useragent", "127.0.0.1", "MyTokenCode", "test.useragent", "127.0.0.1", "MyPrefix", 1);
    failingFactsArray ~= ExtendTokenFacts(true, Clock.currTime().toUnixTime() - 10, "test.useragent", "127.0.0.1", "MyTokenCode", "test.useragent", "127.0.0.1", "MyPrefix", 1);
    failingFactsArray ~= ExtendTokenFacts(true, Clock.currTime().toUnixTime() + 99999999, "", "127.0.0.1", "MyTokenCode", "test.useragent", "127.0.0.1", "MyPrefix", 1);
    failingFactsArray ~= ExtendTokenFacts(true, Clock.currTime().toUnixTime() + 99999999, "test.useragent", "", "MyTokenCode", "test.useragent", "127.0.0.1", "MyPrefix", 1);
    failingFactsArray ~= ExtendTokenFacts(true, Clock.currTime().toUnixTime() + 99999999, "test.useragent", "127.0.0.1", "", "test.useragent", "127.0.0.1", "MyPrefix", 1);
    failingFactsArray ~= ExtendTokenFacts(true, Clock.currTime().toUnixTime() + 99999999, "test.useragent", "127.0.0.1", "MyTokenCode", "", "127.0.0.1", "MyPrefix", 1);
    failingFactsArray ~= ExtendTokenFacts(true, Clock.currTime().toUnixTime() + 99999999, "test.useragent", "127.0.0.1", "MyTokenCode", "test.useragent", "", "MyPrefix", 1);
    failingFactsArray ~= ExtendTokenFacts(true, Clock.currTime().toUnixTime() + 99999999, "test.useragent", "127.0.0.1", "MyTokenCode", "test.useragent", "127.0.0.1", "", 1);
    failingFactsArray ~= ExtendTokenFacts(true, Clock.currTime().toUnixTime() + 99999999, "test.useragent", "127.0.0.1", "MyTokenCode", "test.useragent", "127.0.0.1", "MyPrefix", 0);
    failingFactsArray ~= ExtendTokenFacts(true, Clock.currTime().toUnixTime() + 99999999, "test.useragent", "127.0.0.1", "MyTokenCode", "different.useragent", "127.0.0.1", "MyPrefix", 1);
    failingFactsArray ~= ExtendTokenFacts(true, Clock.currTime().toUnixTime() + 99999999, "test.useragent", "127.0.0.1", "MyTokenCode", "test.useragent", "129.0.0.1", "MyPrefix", 1);

    foreach(facts; failingFactsArray) {
        TestHelper.testDecisionMaker!(ExtendTokenDM, ExtendTokenFacts)(facts, 0, true);    
    }
}