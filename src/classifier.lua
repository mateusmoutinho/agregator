-- return true if good and false if bad or nil if not sure
function clasify_modification_once(props, old, new, goal_instructions   )
    local MAX_TRIES = 5
    for i = 1, MAX_TRIES do
        local llm = newLLM({model = props.classifier_model})

        llm.add_system_prompt([[
            you are a classifier that determines if a modification is good or bad based on the goal instructions provided.
            use the function set_as_good() to set the modification as good and set_as_bad() to set it as bad.
            you must use the function set_as_good() or set_as_bad() to classify the modification.
            set as bad if useful content was removed,
            set as bad if redundant information was added 
            set as bad if non-related information to the goals was set
        ]])
        llm.add_user_prompt("old: " .. old .. "\n")
        llm.add_user_prompt("new: " .. new .. "\n")
        llm.add_user_prompt("goal instructions: " .. goal_instructions .. "\n")
        local is_good = nil

        llm.add_function("set_as_good", "set as good", {}, function()
    
            is_good = true
        end)
        llm.add_function("set_as_bad", "set as bad", {}, function()
            is_good = false
        end)

        llm.generate()
        if is_good ~= nil then
            return is_good
        end
    end
    error("Classifier failed to classify the modification after " .. MAX_TRIES .. " tries.")
end
function clasify_modification(props,old,new,goal_instructions)
    local positive_count = 0
    for i = 1, props.total_classifications do
        local result = clasify_modification_once(props,old,new,goal_instructions )
        if result == true then
            print(string.format("Classification %d: Good modification", i))
            positive_count = positive_count + 1
        end
        if result == false then
            print(string.format("Classification %d: Bad modification", i))
        end
    
    end

    local positive_percent = (positive_count / props.total_classifications) * 100
    print(string.format("\tPositive classifications: %d/%d (%.2f%%)", positive_count, props.total_classifications, positive_percent))
    return positive_percent >= props.min_positive_percent
end
