const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const options = .{
        .use_double_precision = b.option(
            bool,
            "use_double_precision",
            "Enable double precision",
        ) orelse false,
        .enable_asserts = b.option(
            bool,
            "enable_asserts",
            "Enable assertions",
        ) orelse (optimize == .Debug),
        .enable_cross_platform_determinism = b.option(
            bool,
            "enable_cross_platform_determinism",
            "Enables cross-platform determinism",
        ) orelse true,
        .enable_debug_renderer = b.option(
            bool,
            "enable_debug_renderer",
            "Enable debug renderer",
        ) orelse false,
        .shared = b.option(
            bool,
            "shared",
            "Build JoltC as shared lib",
        ) orelse false,
        .no_exceptions = b.option(
            bool,
            "no_exceptions",
            "Disable C++ Exceptions",
        ) orelse true,
    };

    const jolt = if (options.shared) blk: {
        const lib = b.addSharedLibrary(.{
            .name = "jolt",
            .target = target,
            .optimize = optimize,
        });
        if (target.result.os.tag == .windows) {
            lib.root_module.addCMacro("JPC_API", "extern __declspec(dllexport)");
        }
        break :blk lib;
    } else b.addStaticLibrary(.{
        .name = "jolt",
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(jolt);

    const jolt_physics_dep = b.dependency("JoltPhysics", .{});

    jolt.addIncludePath(jolt_physics_dep.path("."));
    if (target.result.abi != .msvc) {
        jolt.linkLibCpp();
    } else {
        jolt.linkSystemLibrary("advapi32");
    }

    const flags = &.{
        "-std=c++17",
        if (options.enable_cross_platform_determinism) "-DJPH_CROSS_PLATFORM_DETERMINISTIC" else "",
        if (options.enable_debug_renderer) "-DJPH_DEBUG_RENDERER" else "",
        if (options.use_double_precision) "-DJPH_DOUBLE_PRECISION" else "",
        if (options.enable_asserts) "-DJPH_ENABLE_ASSERTS" else "",
        if (options.no_exceptions) "-fno-exceptions" else "",
        "-fno-access-control",
        "-fno-sanitize=undefined",
    };

    jolt.addCSourceFiles(.{
        .root = jolt_physics_dep.path("Jolt"),
        .files = &.{
            "AABBTree/AABBTreeBuilder.cpp",
            "Core/Color.cpp",
            "Core/Factory.cpp",
            "Core/IssueReporting.cpp",
            "Core/JobSystemSingleThreaded.cpp",
            "Core/JobSystemThreadPool.cpp",
            "Core/JobSystemWithBarrier.cpp",
            "Core/LinearCurve.cpp",
            "Core/Memory.cpp",
            "Core/Profiler.cpp",
            "Core/RTTI.cpp",
            "Core/Semaphore.cpp",
            "Core/StringTools.cpp",
            "Core/TickCounter.cpp",
            "Geometry/ConvexHullBuilder.cpp",
            "Geometry/ConvexHullBuilder2D.cpp",
            "Geometry/Indexify.cpp",
            "Geometry/OrientedBox.cpp",
            "Math/Vec3.cpp",
            "ObjectStream/SerializableObject.cpp",
            "Physics/Body/Body.cpp",
            "Physics/Body/BodyCreationSettings.cpp",
            "Physics/Body/BodyInterface.cpp",
            "Physics/Body/BodyManager.cpp",
            "Physics/Body/MassProperties.cpp",
            "Physics/Body/MotionProperties.cpp",
            "Physics/Character/Character.cpp",
            "Physics/Character/CharacterBase.cpp",
            "Physics/Character/CharacterVirtual.cpp",
            "Physics/Collision/BroadPhase/BroadPhase.cpp",
            "Physics/Collision/BroadPhase/BroadPhaseBruteForce.cpp",
            "Physics/Collision/BroadPhase/BroadPhaseQuadTree.cpp",
            "Physics/Collision/BroadPhase/QuadTree.cpp",
            "Physics/Collision/CastConvexVsTriangles.cpp",
            "Physics/Collision/CastSphereVsTriangles.cpp",
            "Physics/Collision/CollideConvexVsTriangles.cpp",
            "Physics/Collision/CollideSphereVsTriangles.cpp",
            "Physics/Collision/CollisionDispatch.cpp",
            "Physics/Collision/CollisionGroup.cpp",
            "Physics/Collision/EstimateCollisionResponse.cpp",
            "Physics/Collision/GroupFilter.cpp",
            "Physics/Collision/GroupFilterTable.cpp",
            "Physics/Collision/ManifoldBetweenTwoFaces.cpp",
            "Physics/Collision/NarrowPhaseQuery.cpp",
            "Physics/Collision/NarrowPhaseStats.cpp",
            "Physics/Collision/PhysicsMaterial.cpp",
            "Physics/Collision/PhysicsMaterialSimple.cpp",
            "Physics/Collision/Shape/BoxShape.cpp",
            "Physics/Collision/Shape/CapsuleShape.cpp",
            "Physics/Collision/Shape/CompoundShape.cpp",
            "Physics/Collision/Shape/ConvexHullShape.cpp",
            "Physics/Collision/Shape/ConvexShape.cpp",
            "Physics/Collision/Shape/CylinderShape.cpp",
            "Physics/Collision/Shape/DecoratedShape.cpp",
            "Physics/Collision/Shape/EmptyShape.cpp",
            "Physics/Collision/Shape/HeightFieldShape.cpp",
            "Physics/Collision/Shape/MeshShape.cpp",
            "Physics/Collision/Shape/MutableCompoundShape.cpp",
            "Physics/Collision/Shape/OffsetCenterOfMassShape.cpp",
            "Physics/Collision/Shape/PlaneShape.cpp",
            "Physics/Collision/Shape/RotatedTranslatedShape.cpp",
            "Physics/Collision/Shape/ScaledShape.cpp",
            "Physics/Collision/Shape/Shape.cpp",
            "Physics/Collision/Shape/SphereShape.cpp",
            "Physics/Collision/Shape/StaticCompoundShape.cpp",
            "Physics/Collision/Shape/TaperedCapsuleShape.cpp",
            "Physics/Collision/Shape/TaperedCylinderShape.cpp",
            "Physics/Collision/Shape/TriangleShape.cpp",
            "Physics/Collision/TransformedShape.cpp",
            "Physics/Constraints/ConeConstraint.cpp",
            "Physics/Constraints/Constraint.cpp",
            "Physics/Constraints/ConstraintManager.cpp",
            "Physics/Constraints/ContactConstraintManager.cpp",
            "Physics/Constraints/DistanceConstraint.cpp",
            "Physics/Constraints/FixedConstraint.cpp",
            "Physics/Constraints/GearConstraint.cpp",
            "Physics/Constraints/HingeConstraint.cpp",
            "Physics/Constraints/MotorSettings.cpp",
            "Physics/Constraints/PathConstraint.cpp",
            "Physics/Constraints/PathConstraintPath.cpp",
            "Physics/Constraints/PathConstraintPathHermite.cpp",
            "Physics/Constraints/PointConstraint.cpp",
            "Physics/Constraints/PulleyConstraint.cpp",
            "Physics/Constraints/RackAndPinionConstraint.cpp",
            "Physics/Constraints/SixDOFConstraint.cpp",
            "Physics/Constraints/SliderConstraint.cpp",
            "Physics/Constraints/SpringSettings.cpp",
            "Physics/Constraints/SwingTwistConstraint.cpp",
            "Physics/Constraints/TwoBodyConstraint.cpp",
            "Physics/DeterminismLog.cpp",
            "Physics/IslandBuilder.cpp",
            "Physics/LargeIslandSplitter.cpp",
            "Physics/PhysicsScene.cpp",
            "Physics/PhysicsSystem.cpp",
            "Physics/PhysicsUpdateContext.cpp",
            "Physics/Ragdoll/Ragdoll.cpp",
            "Physics/SoftBody/SoftBodyCreationSettings.cpp",
            "Physics/SoftBody/SoftBodyMotionProperties.cpp",
            "Physics/SoftBody/SoftBodyShape.cpp",
            "Physics/SoftBody/SoftBodySharedSettings.cpp",
            "Physics/StateRecorderImpl.cpp",
            "Physics/Vehicle/MotorcycleController.cpp",
            "Physics/Vehicle/TrackedVehicleController.cpp",
            "Physics/Vehicle/VehicleAntiRollBar.cpp",
            "Physics/Vehicle/VehicleCollisionTester.cpp",
            "Physics/Vehicle/VehicleConstraint.cpp",
            "Physics/Vehicle/VehicleController.cpp",
            "Physics/Vehicle/VehicleDifferential.cpp",
            "Physics/Vehicle/VehicleEngine.cpp",
            "Physics/Vehicle/VehicleTrack.cpp",
            "Physics/Vehicle/VehicleTransmission.cpp",
            "Physics/Vehicle/Wheel.cpp",
            "Physics/Vehicle/WheeledVehicleController.cpp",
            "RegisterTypes.cpp",
            "Renderer/DebugRenderer.cpp",
            "Renderer/DebugRendererPlayback.cpp",
            "Renderer/DebugRendererRecorder.cpp",
            "Renderer/DebugRendererSimple.cpp",
            "Skeleton/SkeletalAnimation.cpp",
            "Skeleton/Skeleton.cpp",
            "Skeleton/SkeletonMapper.cpp",
            "Skeleton/SkeletonPose.cpp",
            "TriangleSplitter/TriangleSplitter.cpp",
            "TriangleSplitter/TriangleSplitterBinning.cpp",
            "TriangleSplitter/TriangleSplitterMean.cpp",
        },
        .flags = flags,
    });
}
