#!/usr/bin/env python3
"""
Test script for running LAMA planner with the expressive domain.
"""
import os
import subprocess
import sys
from pathlib import Path

def clear_screen():
    """Clear the terminal screen."""
    os.system('cls' if os.name == 'nt' else 'clear')

def test_lama_planner(domain_file="domain_expressive.pddl", problem_file="problem_expressive.pddl"):
    """Test the LAMA planner with the expressive domain."""
    print(f"📝 Testing LAMA planner with domain:{domain_file} and problem:{problem_file}")
    
    # Paths
    lama_path = "./lama_planner/fast-downward.py"
    
    # Check if files exist
    for file_path in [domain_file, problem_file, lama_path]:
        if not Path(file_path).exists():
            print(f"❌ Error: File {file_path} does not exist")
            return False

    # Run LAMA planner
    cmd = [lama_path, "--alias", "lama", domain_file, problem_file]
    print(f"\n🚀 Running command: {' '.join(cmd)}\n")

    try:
        process = subprocess.run(cmd, 
                                capture_output=True, 
                                text=True, 
                                check=True)
        
        # Extract plan from output
        print("\n✅ Planning successful!")
        print("\n📋 Generated Plan:")
        print("-" * 50)
        
        if os.path.exists("sas_plan.1"):
            with open("sas_plan.1", "r") as plan_file:
                plan = plan_file.read()
                print(plan)
        else:
            # Try to extract plan from stdout
            lines = process.stdout.split('\n')
            plan_start = False
            plan = []
            for line in lines:
                if line.startswith("fill-slot") or line.startswith("complete-pipeline"):
                    plan_start = True
                    plan.append(line)
                elif plan_start and not line.strip():
                    break
            
            if plan:
                print("\n".join(plan))
            else:
                print("Could not find plan in output")
                print("\nPlanner output:")
                print(process.stdout)
        
        print("-" * 50)
        return True

    except subprocess.CalledProcessError as e:
        print(f"❌ Error running planner: {e}")
        print("\nStdout:")
        print(e.stdout)
        print("\nStderr:")
        print(e.stderr)
        return False

if __name__ == "__main__":
    clear_screen()
    print("=" * 80)
    print("🧠 LAMA Planner Test for Expressive Biosignal Pipeline Domain")
    print("=" * 80)
    print("\nThis script tests the LAMA planner with our expressive domain that supports")
    print("existential quantifiers, universal quantifiers, and derived predicates.\n")
    
    # Parse command line arguments if provided
    domain_file = "domain_expressive.pddl"
    problem_file = "problem_expressive.pddl"
    
    if len(sys.argv) > 1:
        domain_file = sys.argv[1]
    if len(sys.argv) > 2:
        problem_file = sys.argv[2]
    
    success = test_lama_planner(domain_file, problem_file)
    
    if success:
        print("\n✅ Test completed successfully!")
    else:
        print("\n❌ Test failed!")
    
    print("\nDone.")
    sys.exit(0 if success else 1) 