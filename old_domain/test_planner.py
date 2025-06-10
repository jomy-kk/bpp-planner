import unified_planning as up
from unified_planning.io import PDDLReader
from unified_planning.shortcuts import *
import sys

def test_pddl_parsing(domain_file='domain.pddl', problem_file='problem.pddl'):
    """Test if our PDDL files can be parsed successfully"""
    print("Testing PDDL file parsing...")
    
    try:
        # Read our domain and problem
        reader = PDDLReader()
        problem = reader.parse_problem(domain_file, problem_file)
        
        print('✅ Successfully parsed PDDL files!')
        print(f'Problem name: {problem.name}')
        print(f'Objects: {len(problem.all_objects)}')
        print(f'Actions: {len(problem.actions)}')
        print(f'Fluents: {len(problem.fluents)}')
        
        print('\nFluents:')
        for f in problem.fluents:
            print(f'  - {f}')
            
        print('\nActions:')
        for a in problem.actions:
            print(f'  - {a}')
            
        print('\nGoals:')
        for g in problem.goals:
            print(f'  - {g}')
            
        return problem
        
    except Exception as e:
        print(f'❌ Error parsing PDDL: {e}')
        import traceback
        traceback.print_exc()
        return None

def test_planner(problem):
    """Test if we can find a planner and solve the problem"""
    if problem is None:
        print("Cannot test planner - problem parsing failed")
        return
    
    print("\n" + "="*50)
    print("Testing planner...")
    
    try:
        # Try to get a suitable planner
        with OneshotPlanner(name='fast-downward') as planner:
            print(f"Using planner: {planner.name}")
            result = planner.solve(problem)
            
            if result.status == up.engines.PlanGenerationResultStatus.SOLVED_SATISFICING:
                print("✅ Problem solved successfully!")
                print(f"Plan length: {len(result.plan.actions)}")
                print("\nPlan:")
                for i, action in enumerate(result.plan.actions):
                    print(f"  {i+1}. {action}")
            else:
                print(f"❌ Planning failed with status: {result.status}")
                
    except Exception as e:
        print(f"❌ Planner error: {e}")
        
        # Try alternative planners
        print("\nTrying alternative planners...")
        try:
            with OneshotPlanner(name='pyperplan') as planner:
                print(f"Using planner: {planner.name}")
                result = planner.solve(problem)
                
                if result.status == up.engines.PlanGenerationResultStatus.SOLVED_SATISFICING:
                    print("✅ Problem solved successfully!")
                    print(f"Plan length: {len(result.plan.actions)}")
                    print("\nPlan:")
                    for i, action in enumerate(result.plan.actions):
                        print(f"  {i+1}. {action}")
                else:
                    print(f"❌ Planning failed with status: {result.status}")
        except Exception as e2:
            print(f"❌ Alternative planner error: {e2}")

if __name__ == "__main__":
    domain_file = 'domain.pddl'
    problem_file = 'problem.pddl'
    
    # Parse command line arguments if provided
    if len(sys.argv) > 1:
        domain_file = sys.argv[1]
    if len(sys.argv) > 2:
        problem_file = sys.argv[2]
    
    print(f"Using domain: {domain_file}")
    print(f"Using problem: {problem_file}")
    
    problem = test_pddl_parsing(domain_file, problem_file)
    test_planner(problem) 