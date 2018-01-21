module commands.login;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;
import decisionmakers.login;

class LoginCommand : AbstractEvent!LoginDMMeta,StorableEvent
{
    this(LoginDMMeta meta)
    {
        super(meta);
    }

    public StorageEvent toStorageEvent() {
        auto lifecycle = this.getLifecycle();
        auto metadata = this.getMetadata();

        auto LoginDMMeta = *metadata.peek!(LoginDMMeta);
        return new StorageEvent(typeid(this), lifecycle, LoginDMMeta.serializeToJson());       
    }
}