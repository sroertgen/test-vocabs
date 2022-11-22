while getopts f:s:l: flag
do
    case "${flag}" in
        f) file=${OPTARG};;
        s) shape=${OPTARG};;
        l) severity=${OPTARG};;
    esac
done

# check file is not empty
test $(wc -l $file | awk '{print $1}') -gt 0 || echo "file has no lines, aborting" && exit 1

echo "Validate: docker run --rm -v $shape:/rdf/shape.ttl -v $file:/rdf/file.ttl laocoon667/jena:4.6.1 shacl v -s /rdf/shape.ttl -d /rdf/file.ttl > result.ttl"
docker run --rm -v $shape:/rdf/shape.ttl -v $file:/rdf/file.ttl laocoon667/jena:4.6.1 shacl v -s /rdf/shape.ttl -d /rdf/file.ttl > result.ttl

# check exit status for validation
# if the test file is invalid docker will return a non-zero exit status
# we should then break
test $? -eq 0 || echo "something bad happened; maybe riot validation failed, aborting" && exit 1

# Parse the validation to check for errors
echo "Parse Validation: docker run --rm -v $(pwd)/scripts/check-for-violation.rq:/rdf/check-for-violation.rq -v $(pwd)/result.ttl:/rdf/result.ttl laocoon667/jena:4.6.1 arq --data /rdf/result.ttl --query /rdf/check-for-violation.rq"
validationResult="$(docker run --rm -v $(pwd)/scripts/check-for-violation.rq:/rdf/check-for-violation.rq -v $(pwd)/result.ttl:/rdf/result.ttl laocoon667/jena:4.6.1 arq --data /rdf/result.ttl --query /rdf/check-for-violation.rq)"

lines=$(echo "$validationResult" | wc -l )

# print validation result for informational purposes
echo "$validationResult"

# an empty result, i.e. a correct validation has 4 lines of output
test ${lines} -gt 4 || echo "validation errors" && exit 1