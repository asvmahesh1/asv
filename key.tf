resource "aws_key_pair" "chef1" {
  key_name = "chef1"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}
