module "kinesis" {
  source = "../.."
  context = module.context.self

  shard_count = var.shard_count
}
