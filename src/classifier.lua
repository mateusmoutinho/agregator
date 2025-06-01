-- return true if good and false if bad or nil if not sure
function clasify_modification_once(old,new,goal_instructions,classifier_model)
    local llm = newLLM({model=classifier_model})

    llm.add_system_prompt([[
        you are a classifier that determines if a modification is good or bad based on the goal instructions provided.
        use the function set_as_good() to set the modification as good and set_as_bad() to set it as bad.
        you must use the function set_as_good() or set_as_bad() to classify the modification.
    ]])
    llm.add_user_prompt("old: " .. old.."\n")
    llm.add_user_prompt("new: " .. new .. "\n")
    llm.add_user_prompt("goal instructions: " .. goal_instructions .. "\n")
    local is_good = nil

    llm.add_function("set_as_good","set as good",{}, function()
        is_good = true
    end)
    llm.add_function("set_as_bad","set as bad",{}, function()
        is_good = false
    end)

    llm.generate()
    return is_good
end 

