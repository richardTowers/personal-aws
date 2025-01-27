resource "aws_vpc" "this" {
  tags = {
    Name = "deliberatepractice-dev"
  }
  cidr_block = "10.0.0.0/26"
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_subnet" "this" {
  cidr_block = "10.0.0.0/28"
  vpc_id     = aws_vpc.this.id
}

resource "aws_route_table_association" "this" {
  route_table_id = aws_route_table.this.id
  subnet_id      = aws_subnet.this.id
}

