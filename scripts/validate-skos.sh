while getopts f:s:l: flag
do
    case "${flag}" in
        f) file=${OPTARG};;
        s) shape=${OPTARG};;
        l) severity=${OPTARG};;
    esac
done

echo "Validate: docker run --rm -v $shape:/rdf/shape.ttl -v $file:/rdf/file.ttl laocoon667/jena:4.6.1 shacl v -s /rdf/shape.ttl -d /rdf/file.ttl > result.ttl"
docker run --rm -v $shape:/rdf/shape.ttl -v $file:/rdf/file.ttl laocoon667/jena:4.6.1 shacl v -s /rdf/shape.ttl -d /rdf/file.ttl > result.ttl

echo "Parse Validation: docker run --rm -v $(pwd)/scripts/check-for-violation.rq:/rdf/check-for-violation.rq -v $(pwd)/result.ttl:/rdf/result.ttl laocoon667/jena:4.6.1 arq --data /rdf/result.ttl --query /rdf/check-for-violation.rq"

validationResult="$(docker run --rm -v $(pwd)/scripts/check-for-violation.rq:/rdf/check-for-violation.rq -v $(pwd)/result.ttl:/rdf/result.ttl laocoon667/jena:4.6.1 arq --data /rdf/result.ttl --query /rdf/check-for-violation.rq)"
lines=$(echo "$validationResult" | wc -l )
echo "$validationResult"
echo $lines

# an empty result, i.e. a correct validation has 4 lines of output
[[ ${lines} -gt 4 ]] && echo "validation errors" && exit 1 || echo "no validation errors"