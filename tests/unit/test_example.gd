extends GutTest


# Setup
func before_each() -> void:
	gut.p("ran setup", 2)


func after_each() -> void:
	gut.p("ran teardown", 2)


func before_all() -> void:
	gut.p("ran setup for all", 2)


func after_all() -> void:
	gut.p("ran teardown for all", 2)


# Tests
func test_assert_eq_number_not_equal() -> void:
	assert_ne(1, 2, "1 != 2")


func test_assert_eq_number_equal() -> void:
	assert_eq("asdf", "asdf", "Should pass")


func test_assert_true_with_true():
	assert_true(true, "Should pass, true is true")
