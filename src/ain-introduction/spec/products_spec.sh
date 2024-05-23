Describe "CRUD products"
  Describe "Get product"
    getProductTitlebyID(){
      ID=$1 ain base.ain get-product.ain | jq -r .title
    }

    Parameters
      "#1" 1 "iPhone 9"
      "#2" 2 "iPhone X"
    End

    Example "Get product with ID $1"
      When call getProductTitlebyID $2
      The output should equal "$3"
    End
  End

  Describe "Add product"
    addProduct(){
      ain base.ain add-products.ain | jq .id
    }

    It "Add product Correctly"
      When call addProduct
      The output should eq 101
    End
  End
End
