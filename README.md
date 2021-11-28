personal-aws
============

Infrastructure as code for my personal AWS account.

remote-state
------------

Creates the S3 bucket the other projects use to store their remote state. The statefile for this project is committed to git.

gmail prometheus exporter
-------------------------

Runs prometheus-gmail-exporter-go in an ECS Fargate container.

Scraped by an amazon managed prometheus cluster, which remote writes to grafana cloud.

