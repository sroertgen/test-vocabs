while getopts f:s:l: flag
do
    case "${flag}" in
        f) file=${OPTARG};;
        s) shape=${OPTARG};;
        l) severity=${OPTARG};;
    esac
done

echo "docker run --rm -v $(pwd)/$shape:/rdf/shape.ttl -v $(pwd)/$file:/rdf/file.ttl laocoon667/jena:4.6.1 shacl v -s /rdf/shape.ttl -d /rdf/file.ttl > result.ttl"
docker run --rm -v $(pwd)/$shape:/rdf/shape.ttl -v $(pwd)/$file:/rdf/file.ttl laocoon667/jena:4.6.1 shacl v -s /rdf/shape.ttl -d /rdf/file.ttl > result.ttl

validationResult="$(docker run --rm -v $(pwd)/scripts/check-for-violation.rq:/rdf/check-for-violation.rq -v $(pwd)/result.ttl:/rdf/result.ttl laocoon667/jena:4.6.1 arq --data /rdf/result.ttl --query /rdf/check-for-violation.rq)"
lines=$(echo "$validationResult" | wc -l )
echo "$validationResult"
echo $lines

# an empty result, i.e. a correct validation has 4 lines of output
[[ ${lines} -gt 4 ]] && echo "validation errors" || echo "no validation errors"