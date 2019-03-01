resource "aws_iam_group_policy_attachment" "readonly_policy_attachment" {
  policy_arn = "${aws_iam_policy.ReadOnlyAccess.arn}"
  group      = "${aws_iam_group.readOnly.name}"
}

resource "aws_iam_group_policy_attachment" "developer_policy_attachment" {
  policy_arn = "${aws_iam_policy.ReadOnlyAccess.arn}"
  group      = "${aws_iam_group.Debtpaypro-developer.name}"
}
