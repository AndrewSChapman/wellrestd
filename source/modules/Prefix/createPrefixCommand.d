module commands.createprefix;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;
import decisionmakers.createprefix;

class CreatePrefixCommand : AbstractEvent!CreatePrefixDMMeta,StorableEvent
{
    this(CreatePrefixDMMeta meta)
    {
        super(meta);
    }

    public StorageEvent toStorageEvent() {
        auto lifecycle = this.getLifecycle();
        auto metadata = this.getMetadata();

        auto commandMeta = *metadata.peek!(CreatePrefixDMMeta);
        return new StorageEvent(typeid(this), lifecycle, commandMeta.serializeToJson());       
    }
}