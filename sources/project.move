module 0x317cc7d3c13b6d63cbced734ff4e9ca86216a67bb255c43498fd66de5d179236::EventLogger {
    use aptos_framework::signer;
    use aptos_framework::event;
    use std::string::String;
    use std::vector;

    /// Struct to store event data
    struct EventData has store, key {
        events: vector<EventRecord>,
    }

    /// Individual event record
    struct EventRecord has store, drop, copy {
        event_id: u64,
        message: String,
        timestamp: u64,
        logger: address,
    }

    /// Event emitted when a new log is created
    #[event]
    struct LogEvent has drop, store {
        event_id: u64,
        message: String,
        timestamp: u64,
        logger: address,
    }

    /// Function to initialize event logger for an account
    public fun initialize_logger(account: &signer) {
        let event_data = EventData {
            events: vector::empty<EventRecord>(),
        };
        move_to(account, event_data);
    }

    /// Function to log a new event with message and timestamp
    public fun log_event(
        logger: &signer, 
        message: String, 
        timestamp: u64
    ) acquires EventData {
        let logger_address = signer::address_of(logger);
        
        // Initialize if not exists
        if (!exists<EventData>(logger_address)) {
            initialize_logger(logger);
        };
        
        let event_data = borrow_global_mut<EventData>(logger_address);
        let event_id = vector::length(&event_data.events) + 1;
        
        let new_event = EventRecord {
            event_id,
            message,
            timestamp,
            logger: logger_address,
        };
        
        vector::push_back(&mut event_data.events, new_event);
        
        // Emit event
        event::emit(LogEvent {
            event_id,
            message,
            timestamp,
            logger: logger_address,
        });
    }
}