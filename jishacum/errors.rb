class JishacumError
    class OwnerIDNotDefined < StandardError
        def message
            "Owner ID is not defined. Please put your ID in the OWNER_ID or OWNER_IDS variable in the config.rb file."
        end
    end

    class InconsistentOwnerVariables < StandardError
        def message
            "OWNER_ID and OWNER_IDS can't be assigned together. Please assign your ID either only in OWNER_ID (or OWNER_IDS if this bot is owned by a team)."
        end
    end

    class InvalidOwnerID < StandardError; end
end