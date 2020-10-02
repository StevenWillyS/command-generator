EXT="java"
COMMAND_DIRECTORY=""
COMMAND_IMPL_DIRECTORY=""
COMMAND_IMPL_TEST_DIRECTORY=""
COMMAND_MODEL_DIRECTORY=""



findCommandDirectory() {
	find ./ -name "command" | grep "command/" | grep "src/"
}

findCommandImplDirectory() {
	find ./ -name "impl" | grep "command" | grep "main/"
}

findCommandImplTestDirectory() {
	find ./ -name "impl" | grep "command" | grep "test/"
}

findCommandModelDirectory() {
	find ./ -name "model" | grep "command" | grep "src/"
}



getPackageFromDirectory() {
	DIRECTORY=$1

	directoryArray=(${DIRECTORY//\// })
	afterJava="false"
	package=""
	
	for currentDirectory in "${directoryArray[@]}"; do
		if [[ $afterJava == "true" ]]; then
			if [[ $package == "" ]]; then
				package="$currentDirectory"
			else
				package="$package.$currentDirectory"
			fi
		fi
		
		if [[ $currentDirectory == "java" ]]; then
			afterJava="true"
		fi
	done
	
	echo $package
}

printPackage() {
	echo "package $(getPackageFromDirectory $1);"
}



lombokBasicImport() {
	cat <<-EOF
	import lombok.AllArgsConstructor;
	import lombok.Builder;
	import lombok.Data;
	import lombok.NoArgsConstructor;
	EOF
}

importClass() {
	echo "import $(getPackageFromDirectory $1).$2;"
}

importSlf4j() {
	echo "import lombok.extern.slf4j.Slf4j;"
}

importSpringframeworkService() {
	echo "import org.springframework.stereotype.Service;"
}

createBasicInterfaceHeader() {
	FILENAME=$1
	CLASSNAME=$2
	MODEL_CLASSNAME=$3
	
	cat <<-EOF >> "$COMMAND_DIRECTORY/$FILENAME"
	$(printPackage $COMMAND_DIRECTORY)
	
	$(importClass $COMMAND_MODEL_DIRECTORY $MODEL_CLASSNAME)
	
	public interface $CLASSNAME extends Command<$MODEL_CLASSNAME, Boolean> {
	}
	EOF
}


createBasicImplHeader() {
	FILENAME=$1
	CLASSNAME=$2
	INTERFACE_CLASSNAME=$3

	cat <<-EOF >> "$COMMAND_IMPL_DIRECTORY/$FILENAME"
	$(printPackage $COMMAND_IMPL_DIRECTORY)
	
	$(importClass $COMMAND_DIRECTORY $INTERFACE_CLASSNAME)
	$(importSlf4j)
	$(importSpringframeworkService)
	
	@Service
	@Slf4j
	public class $CLASSNAME implements $INTERFACE_CLASSNAME {
	}
	EOF
}


createBasicRequestHeader() {
	FILENAME=$1
	CLASSNAME=$2

	cat <<-EOF >> "$COMMAND_MODEL_DIRECTORY/$FILENAME"
	$(printPackage $COMMAND_MODEL_DIRECTORY)
	
	$(lombokBasicImport)
	
	@Data
	@Builder
	@AllArgsConstructor
	@NoArgsConstructor
	public class $CLASSNAME {
	}
	EOF
}


createBasicClassHeader() {
	FILENAME=$1
	CLASSNAME=$2

	cat <<-EOF >> "$COMMAND_IMPL_TEST_DIRECTORY/$FILENAME"
	$(printPackage $COMMAND_IMPL_DIRECTORY)
	
	public class $CLASSNAME {
	}
	EOF
} 



createCommand() {
	CLASSNAME="$1Command"
	FILENAME="$CLASSNAME.$EXT"
	REQUEST_MODEL_CLASSNAME="${CLASSNAME}Request"
	createBasicInterfaceHeader $FILENAME $CLASSNAME $REQUEST_MODEL_CLASSNAME
}

createCommandImpl() {
	CLASSNAME="$1CommandImpl"
	FILENAME="$CLASSNAME.$EXT"
	INTERFACE_CLASSNAME="$1Command"
	createBasicImplHeader $FILENAME $CLASSNAME $INTERFACE_CLASSNAME
}

createCommandImplTest() {
	CLASSNAME="$1CommandImplTest"
	FILENAME="$CLASSNAME.$EXT"
	createBasicClassHeader $FILENAME $CLASSNAME
}

createCommandModel() {
	CLASSNAME="$1CommandRequest"
	FILENAME="$CLASSNAME.$EXT"
	createBasicRequestHeader $FILENAME $CLASSNAME
}



initializeDirectoryLocation() {
	COMMAND_DIRECTORY=$(findCommandDirectory)
	COMMAND_IMPL_DIRECTORY=$(findCommandImplDirectory)
	COMMAND_IMPL_TEST_DIRECTORY=$(findCommandImplTestDirectory)
	COMMAND_MODEL_DIRECTORY=$(findCommandModelDirectory)
}

createCommandBundle() {
	createCommand $1
	createCommandImpl $1
	createCommandImplTest $1
	createCommandModel $1
}

generateNewCommand() {
	COMMAND_NAME=$1
	initializeDirectoryLocation
	
	createCommandBundle $COMMAND_NAME
}

generateNewCommand $1 && echo "Success Generating Command File"