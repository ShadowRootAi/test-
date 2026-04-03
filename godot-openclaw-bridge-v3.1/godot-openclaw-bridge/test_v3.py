#!/usr/bin/env python3
"""
Test script for Godot Bridge v3.0
Run this to verify everything works
"""

import urllib.request
import json
import sys

def test_bridge():
    base_url = "http://localhost:8080"
    
    print("=" * 60)
    print("🧪 Godot Bridge v3.0 Test Suite")
    print("=" * 60)
    
    tests = [
        ("Status Check", f"{base_url}/?cmd=status"),
        ("Help", f"{base_url}/?cmd=help"),
        ("Scene Tree", f"{base_url}/?cmd=get_scene_tree"),
    ]
    
    passed = 0
    failed = 0
    
    for name, url in tests:
        try:
            print(f"\n📋 Testing: {name}")
            print(f"   URL: {url}")
            
            req = urllib.request.Request(url, method="GET")
            with urllib.request.urlopen(req, timeout=2) as response:
                data = json.loads(response.read().decode())
                
                if "error" in data and data.get("error"):
                    print(f"   ❌ FAILED: {data['error']}")
                    failed += 1
                else:
                    print(f"   ✅ PASSED")
                    print(f"   ⏱️  Time: {data.get('_timing', {}).get('total_ms', 'N/A')}ms")
                    passed += 1
                    
        except Exception as e:
            print(f"   ❌ ERROR: {e}")
            failed += 1
    
    # Test batch command
    print(f"\n📋 Testing: Batch Commands")
    try:
        batch_data = json.dumps({
            "batch": [
                {"cmd": "status"},
                {"cmd": "get_scene_tree"}
            ]
        }).encode()
        
        req = urllib.request.Request(
            base_url,
            data=batch_data,
            headers={"Content-Type": "application/json"},
            method="POST"
        )
        
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            if data.get("batch"):
                print(f"   ✅ PASSED - Batch executed {data.get('completed', 0)} commands")
                passed += 1
            else:
                print(f"   ❌ FAILED - No batch response")
                failed += 1
    except Exception as e:
        print(f"   ❌ ERROR: {e}")
        failed += 1
    
    print("\n" + "=" * 60)
    print(f"Results: {passed} passed, {failed} failed")
    print("=" * 60)
    
    return failed == 0

if __name__ == "__main__":
    success = test_bridge()
    sys.exit(0 if success else 1)
