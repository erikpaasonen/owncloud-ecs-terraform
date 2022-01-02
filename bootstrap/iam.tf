resource "aws_iam_user" "nc_data" {
  name = "nextcloud-data"
}

resource "aws_iam_access_key" "nc_data" {
  user = aws_iam_user.nc_data.name
}
