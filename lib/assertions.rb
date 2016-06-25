######################################################################
# Module name: Assertions
# File name: assertions.rb
# Description: Contains the assertions methods used by other classes.
######################################################################
module Assertions

    # Description: Aborts the system if the given object is null.
    # Parameters: object.
    # Return: none.
    def assert_object_is_not_null( object )
        if( !object.nil? )
            # Object is not null, nothing to do
        else
            # redirect_to assert_error_null_path
        end
    end

    # Description: Aborts the system if the given object doesn't match the 
    # expected type.
    # Parameters: type_is_correct.
    # Return: none.
    def assert_type_of_object( type_is_correct, expected_type )
        if( type_is_correct.class == expected_type )
            # Object has the expected type, nothing to do
        else
            # redirect_to assert_error_type_of_object_path
        end
    end
end