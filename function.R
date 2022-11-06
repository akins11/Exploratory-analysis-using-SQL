#' Fetch SQL statement query result.
#'
#' @param query a character string containing SQL statement.
#' @param con  a DBI Connection object.
#'
#' @return a data frame
#' @export
#'
#' @examples fetch_res("SELECT * FROM table;")
#' 
fetch_res <- function(query, con = mysqldb) {
  RMariaDB::dbSendStatement(con, query) |>
    RMariaDB::dbFetch()
}


#' Clean column names
#'
#' @param df a data.frame.
#'
#' @return a data.frame
#' @export
#'
#' @examples cl_name(mtcars)
cl_name <- function(df) {
  clean <- function(lab) {
    stringr::str_replace_all(lab, "_", " ") |>
      stringr::str_to_title()
  }
  
  dplyr::rename_with(df, clean)
}



#' GT column label style
#'
#' @param gt gt data object.
#' @param ... additional arguments passed to gt::tab_options() function.
#'
#' @return an object of class gt_tbl.
#' @export
#'
#' @examples gt(mtcars) |> tbl_opts()
#' 
tbl_opts <- function(gt, ...) {
  gt::tab_options(gt,
                  column_labels.border.bottom.color = "#6E6E6E",
                  column_labels.font.weight = "bold",
                  ...)
}



#' Remove unwanted strings
#'
#' @param df data.frame.
#' @param variable a variable in the data "df".
#' @param str the kind of string to remove.
#'
#' @return data.frame with the string 'str' removed.
#' @export
#'
#' @examples data.frame(xx = c("a_sun", "a_moon")) |> remove_str(xx, "a_")
#' 
remove_str <- function(df, variable, str = "\r") {
  var_lab <- ensym(variable)
  
  dplyr::mutate(df, "{var_lab}" := stringr::str_remove({{ variable }}, str))
}



#' product-sales-cost-profit table style functions
#'
#' @param gt gt data object.
#'
#' @return an object of class gt_tbl.
#' @export
#'
#' @examples gt(data) |> prod_sales_cost_profit_gt()
#' 
prod_sales_cost_profit_gt <- function(gt) {
  gt |>
    remove_str(product_name) |>
    cl_name() |>
    gt::gt() |>
    gt::fmt_number(columns = 2:4) |>
    tbl_opts(container.height = gt::px(380)) |>
    gt::data_color(columns = 2:3, colors = "#999999", apply_to = "text") |>
    gtExtras::gt_highlight_rows(rows = 1, columns = 4, fill = "#CFCFCF")
}




#' Location-sales-cost-profit table style functions
#'
#' @param gt gt data object. 
#'
#' @return an object of class gt_tbl.
#' @export
#'
#' @examples gt(data) |> loc_sales_cost_profit_gt()
#' 
loc_sales_cost_profit_gt <- function(gt) {
  gt |>
    cl_name() |>
    gt::gt() |>
    gt::fmt_number(columns = 2:4) |>
    tbl_opts(container.height = gt::px(350)) |>
    gt::data_color(columns = 2:3, colors = "#999999", apply_to = "text") |>
    gtExtras::gt_highlight_rows(columns = 4, rows = 1, fill = "#F7F7F7")
}