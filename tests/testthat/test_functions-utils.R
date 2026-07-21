test_that(".check_directory_content works", {
    expect_error(.check_directory_content(tempdir(), "my_file"), "not found")
    file.create(file.path(tempdir(), "my_file"))
    expect_no_error(.check_directory_content(tempdir(), "my_file"))
    unlink(file.path(tempdir(), "my_file"))
})

test_that(".check_overwriting works", {
    expect_error(.check_overwriting(tempdir()), "contains already")
    expect_no_error(.check_overwriting(file.path(tempdir(), "a")))
})

test_that(".import_process_history works", {
    pth <- tempdir()
    expect_error(.import_process_history(xmse, pth), "process_history.json")
})
