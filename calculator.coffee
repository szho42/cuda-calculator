mainConfig =
    '1.0':
        version: '1.0'
        threadsPerWarp: 32
        warpsPerMultiprocessor: 24
        threadsPerMultiprocessor: 768
        threadBlocksPerMultiprocessor: 8
        sharedMemoryPerMultiprocessor: 16384

        registerFileSize: 8192
        registerAllocationUnitSize: 256

        allocationGranularity: 'block'
        sharedMemoryAllocationUnitSize: 512
        warpAllocationGranularity: 2
    '1.1':
        version: '1.1'
        threadsPerWarp: 32
        warpsPerMultiprocessor: 24
        threadsPerMultiprocessor: 768
        threadBlocksPerMultiprocessor: 8
        sharedMemoryPerMultiprocessor: 16384

        registerFileSize: 8192
        registerAllocationUnitSize: 256

        allocationGranularity: 'block'
        sharedMemoryAllocationUnitSize: 512
        warpAllocationGranularity: 2

    '1.2':
        version: '1.2'
        threadsPerWarp: 32
        warpsPerMultiprocessor: 32
        threadsPerMultiprocessor: 1024
        threadBlocksPerMultiprocessor: 8
        sharedMemoryPerMultiprocessor: 16384

        registerFileSize: 16384
        registerAllocationUnitSize: 512

        allocationGranularity: 'block'
        sharedMemoryAllocationUnitSize: 512
        warpAllocationGranularity: 2
    '1.3':
        version: '1.3'
        threadsPerWarp: 32
        warpsPerMultiprocessor: 32
        threadsPerMultiprocessor: 1024
        threadBlocksPerMultiprocessor: 8
        sharedMemoryPerMultiprocessor: 16384

        registerFileSize: 16384
        registerAllocationUnitSize: 512

        allocationGranularity: 'block'
        sharedMemoryAllocationUnitSize: 512
        warpAllocationGranularity: 2

    '2.0':
        version: '2.0'
        threadsPerWarp: 32
        warpsPerMultiprocessor: 48
        threadsPerMultiprocessor: 1536
        threadBlocksPerMultiprocessor: 8
        sharedMemoryPerMultiprocessor: 49152

        registerFileSize: 32768
        registerAllocationUnitSize: 64

        allocationGranularity: 'warp'
        sharedMemoryAllocationUnitSize: 128



gcd = (a,b) ->
    while (b != 0)
        [a, b] = [b, a % b]
        # b = a % b
        # a = t
    return a

lcm = (a,b) ->
    a*b / gcd(a,b)

ceil = (a,b) ->
    return Math.ceil(a / b) * b


window.calculate = (input) ->

    config = mainConfig[input.version]

    blockWarps = () ->
        Math.ceil(input.threadsPerBlock / config.threadsPerWarp)

    blockRegisters = () ->
        if config.allocationGranularity == 'block'
            ceil( ceil( blockWarps(), config.warpAllocationGranularity ) * input.registersPerThread * config.threadsPerWarp, config.registerAllocationUnitSize )
            # debugger
        else
            ceil(input.registersPerThread * config.threadsPerWarp, config.registerAllocationUnitSize) * blockWarps()


    blockSharedMemory = () ->
        ceil(input.sharedMemoryPerBlock, config.sharedMemoryAllocationUnitSize)

    threadBlocksPerMultiprocessorLimitedByWarpsOrBlocksPerMultiprocessor = () ->
        Math.min(config.threadBlocksPerMultiprocessor, Math.floor(config.warpsPerMultiprocessor / blockWarps()))

    threadBlocksPerMultiprocessorLimitedByRegistersPerMultiprocessor = () ->
        if input.registersPerThread > 0
            Math.floor(config.registerFileSize / blockRegisters())
        else
            config.threadBlocksPerMultiprocessor

    threadBlocksPerMultiprocessorLimitedBySharedMemoryPerMultiprocessor = () ->
        if input.sharedMemoryPerBlock > 0
            Math.floor(config.sharedMemoryPerMultiprocessor / blockSharedMemory())
        else
            config.threadBlocksPerMultiprocessor

    activeThreadsPerMultiprocessor = () ->
        input.threadsPerBlock * activeThreadBlocksPerMultiprocessor()

    activeWarpsPerMultiprocessor = () ->
        activeThreadBlocksPerMultiprocessor() * blockWarps()

    activeThreadBlocksPerMultiprocessor = () ->
        Math.min(
            threadBlocksPerMultiprocessorLimitedByWarpsOrBlocksPerMultiprocessor(),
            threadBlocksPerMultiprocessorLimitedByRegistersPerMultiprocessor(),
            threadBlocksPerMultiprocessorLimitedBySharedMemoryPerMultiprocessor()
        )

    occupancyOfMultiprocessor = () ->
        activeWarpsPerMultiprocessor() / config.warpsPerMultiprocessor


    output =
        activeThreadsPerMultiprocessor: activeThreadsPerMultiprocessor()
        activeWarpsPerMultiprocessor: activeWarpsPerMultiprocessor()
        activeThreadBlocksPerMultiprocessor: activeThreadBlocksPerMultiprocessor()
        occupancyOfMultiprocessor: occupancyOfMultiprocessor()

        blockWarps:         blockWarps()
        blockSharedMemory:  blockSharedMemory()
        blockRegisters:     blockRegisters()

        threadBlocksPerMultiprocessorLimitedByWarpsOrBlocksPerMultiprocessor: threadBlocksPerMultiprocessorLimitedByWarpsOrBlocksPerMultiprocessor()
        threadBlocksPerMultiprocessorLimitedByRegistersPerMultiprocessor: threadBlocksPerMultiprocessorLimitedByRegistersPerMultiprocessor()
        threadBlocksPerMultiprocessorLimitedBySharedMemoryPerMultiprocessor: threadBlocksPerMultiprocessorLimitedBySharedMemoryPerMultiprocessor()



    output = _.extend output, config

    return output

window.calculateGraphs = (input) ->
    graphWarpOccupancyOfThreadsPerBlock = () ->

        current =
            threadsPerBlock: input.threadsPerBlock
            activeWarpsPerMultiprocessor: window.calculate(input).activeWarpsPerMultiprocessor

        inp = _.clone input
        r = []
        for threadsPerBlock in [16..512] by 16
            inp.threadsPerBlock = threadsPerBlock

            r.push({
                threadsPerBlock: threadsPerBlock
                activeWarpsPerMultiprocessor: window.calculate(inp).activeWarpsPerMultiprocessor
            })

        return {
            data: r
            current: current
        }

    graphWarpOccupancyOfRegistersPerThread = () ->

        current =
            registersPerThread: input.registersPerThread
            activeWarpsPerMultiprocessor: window.calculate(input).activeWarpsPerMultiprocessor

        inp = _.clone input
        r = []
        for registersPerThread in [1..128]
            inp.registersPerThread = registersPerThread

            r.push({
                registersPerThread: registersPerThread
                activeWarpsPerMultiprocessor: window.calculate(inp).activeWarpsPerMultiprocessor
            })

        return {
            data: r
            current: current
        }


    graphWarpOccupancyOfSharedMemoryPerBlock = () ->

        current =
            sharedMemoryPerBlock: input.sharedMemoryPerBlock
            activeWarpsPerMultiprocessor: window.calculate(input).activeWarpsPerMultiprocessor


        inp = _.clone input
        r = []
        for sharedMemoryPerBlock in [512..512*100] by 512
            inp.sharedMemoryPerBlock = sharedMemoryPerBlock

            r.push({
                sharedMemoryPerBlock: sharedMemoryPerBlock
                activeWarpsPerMultiprocessor: window.calculate(inp).activeWarpsPerMultiprocessor
            })

        return {
            data: r
            current: current
        }

    output =
        graphWarpOccupancyOfThreadsPerBlock: graphWarpOccupancyOfThreadsPerBlock()
        graphWarpOccupancyOfRegistersPerThread: graphWarpOccupancyOfRegistersPerThread()
        graphWarpOccupancyOfSharedMemoryPerBlock: graphWarpOccupancyOfSharedMemoryPerBlock()

