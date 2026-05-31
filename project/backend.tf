terraform {


  # إعدادات الـ S3 Backend لحفظ ملف الذاكرة وقفله
  backend "s3" {
    bucket  = "cloudthor-2026"         # اسم الـ S3 Bucket الخاص بك (يجب أن يكون فريداً)
    key     = "prod/terraform.tfstate" # المسار واسم الملف داخل الـ Bucket
    region  = "eu-north-1"
    profile = "terraform-dev" # المنطقة المتواجد بها الـ Bucket

    use_lockfile = true # اسم جدول DynamoDB المسؤول عن قفل الملف ومنع التضارب
  }
}

provider "aws" {
  profile = "terraform-dev"
  region  = "eu-north-1"

}



